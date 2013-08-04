#urgentilio

Urgent email to SMS sender.

The app will connect to your email account using IMAP. Any new messages addressed to `<name>+urgent@<domain.tld>` will be checked against a database of already sent messages. Provided these have not been sent yet, we use the [Twilio](http://www.twilio.com/) API to send them.

```bash
$ sudo npm install urgentilio -g
$ touch config.coffee
# http://linux.die.net/man/1/watch
$ watch --color --interval 60 urgentilio
```

The `config.coffee` file is read relative to your current working directory.