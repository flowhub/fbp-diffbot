github = require './github'

main = () ->
  [_node, _script, repo, pr] = process.argv

  config =
    endpoint: 'https://api.github.com'
    token: process.env.GH_TOKEN

  throw new Error 'Missing Github PR repo PR' if not (repo and pr)
  #throw new Error 'Missing Github OAuth token (GH_TOKEN envvar)' if not config.token

  console.log repo, pr
  github.graphsFromPR config, repo, pr
  .then (graphs) ->
    for g in graphs
      console.log 'g', g.filename, g.from.length, g.to.length, g.error
  .catch (err) ->
    console.log 'e', err
    throw err

main() if not module.parent
