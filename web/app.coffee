fbpDiffBot = require '..'

express = require 'express'
bodyParser = require 'body-parser'
debug = require('debug')('fbp-diffbot:app')
bluebird = require 'bluebird'

checkPr = (req, res) ->
  repo = "#{req.params.owner}/#{req.params.repo}"
  pr = req.params.pr
  options = req.query

  debug '/checkpr', repo, pr

  fbpDiffBot.diffbot.checkPr req.config, repo, pr, options
  .then (commentUrl) ->
    return res.status(200).end()
  .catch (err) ->
    console.error '/checkpr', err
    code = err.code or 500
    return res.status(code).end()

githubHook = (req, res) ->
  if req.headers['x-github-event'] != 'pull_request'
    debug '/hooks/github', 'ignoring event type', req.headers['x-github-event']
    return res.status(422).end()

  repoName = req.body.repository.full_name
  pr = req.body.pull_request.number
  options = {}

  debug '/hooks/github', req.body.action, repoName, pr

  fbpDiffBot.diffbot.checkPr req.config, repoName, pr, options
  .then (commentUrl) ->
    return res.status(200).end()
  .catch (err) ->
    console.error '/hooks/github', err
    code = err.code or 500
    return res.status(code).end()

  return res.status(404).end() # FIXME: implement

exports.getApp = getApp = (config) ->
  app = express()

  app.use (req, res, next) ->
    req.config = config # Attach config to request, so handlers can access
    next()

  app.use(bodyParser.json())

  app.post '/checkpr/:owner/:repo/:pr', checkPr
  app.post '/hooks/github', githubHook

  return app

exports.start = (override, callback) ->
  config = fbpDiffBot.common.getConfig override

  app = getApp config
  listenApp = bluebird.promisify app.listen

  fbpDiffBot.webhooks.ensureRepositoryHooks config
  .then (added) ->
    for add in added
      debug 'added webhooks', add.data.url
    if not added.length
      debug 'no webhook additions needed'
    return listenApp config.port
  .then (rr) ->
    app.port = config.port
    return app
  .nodeify callback
