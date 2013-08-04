#!/usr/bin/env coffee
IMAP   = require "imap"
async  = require 'async'
{ _ }  = require 'lodash'
log    = require 'node-logging'
twilio = require 'twilio'
EJDB   = require 'ejdb'

# Open db.
db = EJDB.open __dirname + '/db/db.ejdb'

config = null ; server = null

async.waterfall [ (cb) ->
    try
        config = require "#{process.cwd()}/config.coffee"
    catch err
        return cb err

    cb null

, (cb) ->
    # Build the urgent email.
    [ before, after ] = config.imap.user.split('@')
    config.urgent = "#{before}+urgent@#{after}"

    server = new IMAP config.imap

    server.once 'ready', cb

    server.on 'error', cb

    do server.connect

, (cb) ->
    server.openBox "INBOX", yes, cb

, (inbox, cb) ->
    server.search [ 'UNSEEN', [ 'to', config.urgent ] ], cb

, (uids, cb) ->
    db.find 'messages',
        uid:
            $in: uids
    , (err, cursor, count) ->
        return cb err if err

        # Any results at all?
        return ( cursor.close() ; cb(null, uids) ) if !count
        # Get the array.
        matches = ( cursor.object() while cursor.next() )
        cursor.close()

        # Filter out the matches from uids.
        cb null, _.filter uids, (uid) ->
            !!_.find(matches, ( (match) -> match.uid is uid )).length

, (uids, cb) ->
    return cb null unless uids.length

    client = twilio config.twilio.sid, config.twilio.token

    async.each uids, (uid, cb) ->
        f = server.fetch([ uid ],
            bodies: 'HEADER.FIELDS (FROM SUBJECT DATE)'
        )
        f.on "message", (msg) ->
            msg.on 'body', (stream) ->
                buffer = ''
                
                stream.on 'data', (chunk) ->
                    buffer += chunk.toString('utf8')
                
                stream.once "end", ->
                    headers = IMAP.parseHeader(buffer)
                    log.inf message = headers.from.join(', ') + ': ' + headers.subject[0]

                    client.sendSms
                        to: config.twilio.to
                        from: config.twilio.from
                        body: message
                    , (err) ->
                        return cb err if err

                        # We got sent, save us into the db.
                        db.save 'messages',
                            uid: uid
                            message: message
                            time: + new Date
                        , (err) ->
                            cb err

        f.once "error", cb
    
    , cb

], (err) ->
    log.bad err.message if err
    do server?.end
    process.exit !!err