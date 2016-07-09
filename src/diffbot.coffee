github = require './github'
fbpDiff = require 'fbp-diff'

generateDiffs = (graphs, options) ->
  for g in graphs
    type = g.filename.split('.').pop()
    options.format = type
    g.diff = fbpDiff.diff g.from, g.to, options

main = () ->
  [_node, _script, repo, pr] = process.argv

  config =
    endpoint: 'https://api.github.com'
    token: process.env.GH_TOKEN

  throw new Error 'Missing Github PR repo PR' if not (repo and pr)
  #throw new Error 'Missing Github OAuth token (GH_TOKEN envvar)' if not config.token

  diffOptions = {}

  github.graphsFromPR config, repo, pr
  .then (graphs) ->
    generateDiffs graphs, diffOptions
    for g in graphs
      console.log g.filename
      console.log g.diff, '\n'
  .catch (err) ->
    console.log 'e', err
    throw err

main() if not module.parent
