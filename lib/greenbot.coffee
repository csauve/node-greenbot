greenman = require "greenman"
loadPlugins = require "./pluginLoader"
_ = require "underscore"

module.exports = run: (config) ->
    _.defaults config,
      irc:
        nick: "greenbot"

    bot = new greenman.Bot config.irc.nick

    loadPlugins config.global?.plugins, (plugins) ->
      plugin.init bot, config, plugins for plugin in plugins

      if !config.irc?.server then throw new Error "irc.server is not configured"
      if !config.irc?.options?.channels then throw new Error "irc.options.channels is not configured"

      console.log "Connnecting to #{config.irc.server} as #{config.irc.nick} ( ͡° ͜ʖ ͡°)"
      bot.connect config.irc.server, config.irc.options
