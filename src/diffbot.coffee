github = require './github'
fbpDiff = require 'fbp-diff'

# TODO: move added/removed handling into fbp-diff itself?
nullGraph =
  processes: {}
  connections: []

generateDiffs = (graphs, options) ->
  for g in graphs
    type = g.filename.split('.').pop()
    options.format = type
    from = g.from
    to = g.to
    if type == 'json'
      from = JSON.stringify nullGraph if g.from.length == 0
      to = JSON.stringify nullGraph if g.to.length == 0
    g.diff = fbpDiff.diff from, to, options

# Format Markdown to post as comment
formatComment = (pr) ->
  comment = ""

  from = pr.base.sha.slice(0, 10)
  to = pr.head.sha.slice(0, 10)
  # We add the commit info into the comment, and use this to keep state
  # It is important that the syntax stays compatible, as this forms a stringly API
  comment += "[fbp-diff](https://github.com/flowbased/fbp-diff) for commits `#{from}...#{to}`\n"

  for graph in pr.graphs
    comment += "`#{graph.filename}`:\n"
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
  .then (data) ->
    if data.graphs
      generateDiffs data.graphs, diffOptions
      return formatComment data
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
