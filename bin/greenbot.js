#! /usr/bin/env node

var minimist = require("minimist");
var CSON = require("cson");
var Greenbot = require("..");

var argv = minimist(process.argv.slice(2));
var configPath = argv._[0];
if (!configPath) {
  throw new Error("No config file provided");
}

var config = CSON.parseFileSync(configPath);
var bot = new Greenbot(config);
bot.connect();
