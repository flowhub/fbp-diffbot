github = require './github'
fbpDiff = require 'fbp-diff'

generateDiffs = (graphs, options) ->
  for g in graphs
    type = g.filename.split('.').pop()
    options.format = type
    g.diff = fbpDiff.diff g.from, g.to, options

formatComment = (graphs) ->
  comment = ""

  for graph in graphs
    comment += "[fbp-diff](https://github.com/flowbased/fbp-diff) for `#{graph.filename}`:\n"
    comment += "```\n#{graph.diff}\n```\n"
    comment += "\n"

  return comment

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
    if graphs
      return formatComment graphs
    else
      return null
  .then (maybeComment) ->
    if maybeComment
      console.log 'Posting:\n', maybeComment
      return github.issuePostComment config, repo, pr, maybeComment
    else
      console.log "No changes"
  .catch (err) ->
    console.log 'e', err
    throw err

exports.main = main
main() if not module.parent
