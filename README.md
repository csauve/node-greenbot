# Greenbot
Greenbot is a plugin-oriented IRC bot built on [node-greenman](https://github.com/csauve/node-greenman), a [node-irc](https://github.com/martynsmith/node-irc/tree/0.3.x) wrapper. Plugins are loaded in a configurable order and act in middleware chains, allowing for various handling cases like filtering, message rewriting, logging, and anti-spam. Plugins can also depend on each other to enhance their capabilities. The bot can be run programmatically or from the command line.

## Installation and Usage
Install greenbot globally with NPM:
```sh
$ npm install -g greenbot
```
Now you're ready to set up plugins and create a configuration file.

## Plugin API
A plugins directory is just a collection of node modules as sibling directories, where the directory name is the module name. Greenbot should be able to just `require` the directory to get the plugin. The only other requirement is that plugins must implement an `init` function on their exports. Here is a complete sample plugin that echos messages of the form `!echo <message>` and uses a rate limiting dependency to prevent spam:
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

## Configuration
Create a *config.cson* file or copy the example one in this project. This file will configure how the bot connects to IRC channels, what plugins are loaded and in what order, and how plugins will be individually configured.

```coffee
# The "greenbot" block is only used to setup the bot. All other configuration is of concern to plugins only
greenbot:
  nick: "greenbot"
  server: "irc.example.com"
  # These "options" are passed right through to the underlying dependency, node-irc, on startup
  options:
    floodProtection: true
    floodProtectionDelay: 1000
    channels: [
      "#yourchannel"
    ]
    # Absolute path to the plugins directory
    pluginsDir: "/Users/example/my-greenbot-plugins"
    # List the plugins in pluginsDir you want enabled. See "Why does plugin order matter?" below
    plugins: [
      "ignore",
      "echo"
    ]

# Any additional configuration needed by plugins:

global:
  prefix: "!"

ignore:
  nicks: [
    /.+bot/i
    "ChanServ"
  ]
```

### Why does plugin order matter?
Greenbot is mainly concerned with the idea of plugins, and uses [node-greenman](https://github.com/csauve/node-greenman) as its IRC bot. Greenman allows message handlers to be chained, such that a handler can decide not to pass the message on to subsequent handlers, or even modify the message contents. See the Greenman API for more information. For example, the included "ignore" plugin will only pass messages to the next handler in the chain if they're from non-ignored nicks. Because order matters, the plugin should be listed first.

## Run It
```sh
$ greenbot ./config.cson
```

## Running programmatically
Install greenbot non-globally:
```sh
npm install greenbot
```
Then `require` and construct it with a configuration object the same as documented above:
```coffee
Greenbot = require "greenbot"

bot = new Greenbot(config)
bot.connect()
```

## Alternatives
Not your cup of tea? Check out these other node IRC bots:
* [irc-js-bot](https://github.com/colin-aarts/irc-js-bot)
* [node-ircbot](https://github.com/draggor/node-ircbot)
* [nodebot](https://github.com/Ricket/nodebot)

## License
Licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).
