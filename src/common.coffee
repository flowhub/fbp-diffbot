yaml = require 'js-yaml'
fs = require 'fs'
path = require 'path'

exports.getConfig = (override) ->
  defaults =
    port: process.env.PORT || 3000
    endpoint: 'https://api.github.com'
    token: process.env.GH_TOKEN
    ownurl: 'https://fbp-diffbot.herokuapp.com'

  configPath = path.join __dirname, '..', 'config.yaml'
  config = yaml.safeLoad fs.readFileSync(configPath, 'utf-8')
  for k, v of defaults
    config[k] = v
  for k, v of override
    config[k] = v

  return config
