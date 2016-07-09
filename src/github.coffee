
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
    # console.log 'pr', pr
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
      data.commits = commits
      return data
  .then (data) ->
    bluebird.map data.commits, (commit) ->
      commit = commit.commit
      return axios.get commit.tree.url, request
    .then (requests) ->
      trees = requests.map (r) -> r.data
      graphDirTrees = trees.map (t) ->
        graphDirUrl = null
        for f in t.tree
          if f.path == 'graphs'
            graphDirUrl = f.url
        return graphDirUrl
      .filter (u) ->
        return u?

      bluebird.map graphDirTrees, (u) ->
        return axios.get u
      .then (requests) ->
        graphTrees = requests.map (r) -> r.data

        graphsChanged = []
        for tree in graphTrees
          for file in tree.tree
            if not (file.path in graphsChanged)
              graphsChanged.push file.path
        data.graphsChanged = graphsChanged
        data.commits = null
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
