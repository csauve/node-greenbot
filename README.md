**Note: This project is still in development! Some of this documentation won't apply yet!**

# Greenbot
Greenbot is a plugin-oriented IRC bot built on [node-greenman](https://github.com/csauve/node-greenman). Plugins are loaded in a configurable order and act in middleware chains, allowing for various handling cases like filtering, message rewriting, logging, and anti-spam. Plugins can also depend on each other to enhance their capabilities. The bot can be run programmatically or from the command line.

## Installation and Setup
```sh
# Installing greenbot globally as a command
$ npm install -g greenbot

# Create a sample configuration file and plugins directory in the current directory
$ greenbot init .
```

## Configuration
From the init setup step above, you should have a "sample.config.cson" file for reference. Here's what the options do:

```coffee
irc:
  # nick and server are used to construct the Greenman bot
  nick: "greenbot"
  server: "irc.example.com"
  # these options are passed right through to the underlying dependency, node-irc, on startup
  options:
    floodProtection: true
    floodProtectionDelay: 1000
    channels: [
      "#channel"
    ]

global:
  # `config.global.prefix` can be optionally used by plugins in their message matching for consistency
  prefix: "!"
  plugins:
    # absolute path to the modules directory. todo: should this be provided as a startup arg instead?
    pluginsDir: "/Users/example/greenbot/plugins"
    # plugins in the pluginsDir are loaded in this order:
    enabledPlugins: [
      "ignore"
      "echo"
    ]

# the configuration is open to any additional configuration needed by plugins
ignore:
  nicks: [
    /.+bot/i
    "ChanServ"
  ]
```

## Run It
```sh
$ greenbot ./config.cson
```

## Plugin API
Creating Greenbot plugins is easy: they're just NPM modules implementing an `init` function in their `exports`. Here is a complete sample plugin that echos messages of the form `!echo <message>` and uses a rate limiting dependency to prevent spam:
```coffee
rateLimit = require "nogo"

module.exports = init: (bot, config, plugins) ->
  prefix = config?.global?.prefix || "!"

  limiter = rateLimit
    rate: 0.3
    burst: 2
    strikes: 3
    cooldown: 60

  bot.msg ///^#{prefix}echo\s+(.+)$///i, (nick, channel, match) ->
    limiter nick,
      go: () -> bot.reply nick, channel, match[1]
      no: (strike) -> bot.say nick, "Enhance your calm! (Strike #{strike} of 3)"
```

The arguments to `init` are:

1. `bot`: A Greenman instance. See the [node-greenman](https://github.com/csauve/node-greenman) readme for its full API
2. `config`: The parsed CSON file provided at startup to Greenbot
3. `plugins`: A map of all enabled plugins. This can be used to enhance functionality of plugins if certain other plugins are present

Of course, you can also expose other members on `exports` for other plugins to depend on.

## Todo
* Using Greenbot programmatically
* Greenbot itself should not be responsible for loading plugins. Related to programmatic usage
* Tests

## Alternatives
Not your cup of tea? Check out these other node IRC bots:
* [node-ircbot](https://github.com/draggor/node-ircbot)
* [nodebot](https://github.com/Ricket/nodebot)

## License
Licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).
