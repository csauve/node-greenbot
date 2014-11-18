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