path = require "path"
_ = require "underscore"

module.exports = (pluginsConf, callback) ->
  _.defaults pluginsConf,
    pluginsDir: process.cwd()
    enabledPlugins: null

  if !pluginsConf.enabledPlugins then throw new Error "No plugins enabled"

  plugins = for name in pluginsConf.enabledPlugins
    absolutePath = path.join pluginsConf.pluginsDir, name
    require absolutePath

  callback plugins
