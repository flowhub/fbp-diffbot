fbpDiffBot = require '..'
express = require 'express'

checkPr = (req, res) ->
  repo = "#{req.params.owner}/#{req.params.repo}"
  options = req.query

  fbpDiffBot.diffbot.checkPr req.config, repo, req.params.pr, options
  .then (commentUrl) ->
    return res.status(200).end()
  .catch (err) ->
    code = err.code or 500
    return res.status(code).end()

exports.getApp = getApp = (config) ->
  app = express()

  app.use (req, res, next) ->
    req.config = config # Attach config to request, so handlers can access
    next()

  app.post '/checkpr/:owner/:repo/:pr', checkPr

  return app

exports.start = (override, callback) ->
  defaults =
    port: process.env.PORT || 3000
    endpoint: 'https://api.github.com'
    token: process.env.GH_TOKEN

  config = {}
  for k, v of defaults
    config[k] = v
  for k, v of override
    config[k] = v

  app = getApp config
  app.listen config.port, (err) ->
    return callback err if err
    return callback null, app, config.port