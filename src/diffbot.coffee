github = require './github'
fbpDiff = require 'fbp-diff'
debug = require('debug')('fbp-diffbot:diffbot')

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
  comment += "[fbp-diff](https://github.com/flowbased/fbp-diff) for commits `#{from}...#{to}`\n\n"

  for graph in pr.graphs
    comment += "`#{graph.filename}`:\n"
    comment += "```\n#{graph.diff}\n```\n"
    comment += "\n"

  return comment

parseComment = (comment) ->
  ret =
    fromCommit: null
    toCommit: null
  re = /[fbp\-diff].*`(\w*)...(\w*)`/
  match = re.exec comment
  ret.fromCommit = match[1]
  ret.toCommit = match[2]
  return ret

sameSHA = (a, b) ->
  same = if a.length > b.length
    a.indexOf(b) == 0
  else
    b.indexOf(a) == 0
  return same

hasNewChanges = (config, repo, pr) ->
  github.issueListComments config, repo, pr
  .then (res) ->
    parsed = res.data.map (c) -> parseComment c.body
    github.prGetChanges config, repo, pr
    .then (change) ->
      found = false
      for c in parsed
        sameFrom = sameSHA c.fromCommit, change.base.sha
        sameTo = sameSHA c.toCommit, change.head.sha
        if sameFrom and sameTo
          found = true

      hasChange = (not found)
      return Promise.resolve hasChange

main = () ->
  [_node, _script, repo, pr] = process.argv

  config =
    endpoint: 'https://api.github.com'
    token: process.env.GH_TOKEN

  throw new Error 'Missing Github PR repo PR' if not (repo and pr)
  #throw new Error 'Missing Github OAuth token (GH_TOKEN envvar)' if not config.token

  diffOptions = {}

  hasNewChanges config, repo, pr
  .then (changed) ->
    debug 'changed?', changed, repo, pr
    if changed
      return github.graphsFromPR config, repo, pr
    else
      return Promise.resolve { graphs: null }
  .then (data) ->
    hasGraphs = data.graphs?.length > 0
    debug 'has graphs?', hasGraphs, repo, pr
    if hasGraphs
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
