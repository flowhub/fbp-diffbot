
axios = require 'axios'
bluebird = require 'bluebird'

getFile = (config, repo, path) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token

  url = "#{config.endpoint}/repos/#{repo}/contents/#{path}"
  axios.get url, request

# TODO: find out which files changed. Need to get the commits, then get each of the trees.
# TODO: filter these to only include (probable) FBP graphs
# TODO: get the graphs as blobs
graphsFromPR = (config, repo, number) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token

  url = "#{config.endpoint}/repos/#{repo}/pulls/#{number}"
  axios.get(url, request)
  .then (req) ->
    pr = req.data
    console.log 'pr', pr
    ret =
      commitsUrl: pr.commits_url
      base:
        sha: pr.base.sha
        repo: pr.base.repo.full_name
      head:
        sha: pr.head.sha
        repo: pr.head.repo.full_name
  .then (data) ->
    console.log data
    axios.get(data.commitsUrl, request)
    .then (req) ->
      commits = req.data
      console.log 'commits', commits
      data.commits = commits
      return data
  .then (data) ->
    bluebird.map data.commits, (commit) ->
      commit = commit.commit
      console.log 'COMMIT', commit.tree
      return axios.get commit.tree.url, request
    .then (requests) ->
      trees = requests.map (r) -> r.data
      console.log 'trees', trees.length
      console.log trees[0]
      filesChanged = []
      # FIXME: need to traverse down into graphs/, either recursively or hardcode this dir...
      for tree in trees
        for file in tree.tree
          if not (file.path in filesChanged)
            filesChanged.push file.path
      data.filesChanged = filesChanged
      return data

main = () ->
  [_node, _script, repo, pr] = process.argv

  config =
    endpoint: 'https://api.github.com'
    token: process.env.GH_TOKEN

  throw new Error 'Missing Github PR repo PR' if not (repo and pr)
  #throw new Error 'Missing Github OAuth token (GH_TOKEN envvar)' if not config.token

  console.log repo, pr
  graphsFromPR config, repo, pr
  .then (graphs) ->
    console.log 'sss', graphs
  .catch (err) ->
    console.log 'e', err
    throw err

main() if not module.parent
