path = require "path"
greenman = require "greenman"
_ = require "underscore"

module.exports = class Greenbot
  constructor: (config) ->
    _.defaults config,
      greenbot:
        nick: "greenbot"
        pluginsDir: process.cwd()
        options:
          floodProtection: true
          floodProtectionDelay: 1000
        globals:
          prefix: "!"

    if !config.greenbot.server then throw new Error "IRC server is not configured"
    if !config.greenbot.options?.channels then throw new Error "IRC channels are not configured"
    if !config.greenbot.plugins?.length then throw new Error "No plugins enabled"

    @config = config
    @bot = new greenman.Bot config.greenbot.nick

    # require all the plugins so they're available as init dependencies
    loadedPlugins = {}
    for pluginName in config.greenbot.plugins
      absolutePath = path.join config.greenbot.pluginsDir, pluginName
      loadedPlugins[pluginName] = require absolutePath

    # now init them in the configured order
    for pluginName in config.greenbot.plugins
      loadedPlugins[pluginName].init @bot, config, loadedPlugins

  connect: () ->
    console.log "Connnecting to #{@config.greenbot.server} as #{@config.greenbot.nick} ( ͡° ͜ʖ ͡°)"
    @bot.connect @config.greenbot.server, @config.greenbot.options

