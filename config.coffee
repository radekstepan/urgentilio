#!/usr/bin/env coffee
module.exports =
    
    # These are passed verbatim to `node-imap`.
    imap:
        user: "<name>@<domain>.<tld>"
        # If you use a two-factor auth, you need to generate an app token.
        password: "xxxxxxxxxxxxxxxxxx"
        host: "imap.gmail.com"
        port: 993
        tls: yes
        tlsOptions:
            rejectUnauthorized: no
    
    twilio:
        # Get them at the top of your dashboard.
        sid:   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        token: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        # The number you got from Twilio.
        from:  "+44xxxxxxxxxx"
        # Your cell.
        to:    "+44xxxxxxxxxx"