
axios = require 'axios'
bluebird = require 'bluebird'

getFile = (config, repo, path) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token

  url = "#{config.endpoint}/repos/#{repo}/contents/#{path}"
  axios.get url, request

fileCouldBeGraph = (name) ->
  ext = name.split('.').pop()
  if ext == 'fbp'
    return true
  else if ext == 'json'
    return name not in ['package.json', 'component.json'] 
  else
    return false

# TODO: get the graphs as blobs, before and after change
prGraphsChanged = (config, repo, number) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token

  url = "#{config.endpoint}/repos/#{repo}/pulls/#{number}/files"
  axios.get(url, request)
  .then (req) ->
    files = req.data
    graphs = files.filter (f) -> return fileCouldBeGraph f.filename
    return graphs

prGet = (config, repo, number) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token
  url = "#{config.endpoint}/repos/#{repo}/pulls/#{number}"
  axios.get(url, request).then (request) ->
    return request.data

getAuthenticated = (config, url) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token
  axios.get(url, request)

fileAtRevision = (config, repo, revision, filepath) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token

  axios.get "#{config.endpoint}/repos/#{repo}/git/commits/#{revision}", request
  .then (req) ->
    commit = req.data
    return commit.tree.url
  .then (treeUrl) ->
    r =
      headers: request.headers
      params:
        recursive: 1
    axios.get treeUrl, r
  .then (req) ->
    tree = req.data.tree
    foundUrl = null
    for file in tree
      if file.path == filepath
        foundUrl = file.url
    throw new Error "File #{filepath} does not exist in #{revision} of #{repo}" if not foundUrl
    return foundUrl
  .then (u) ->
    axios.get u, request
    .then (res) ->
      contents = new Buffer(res.data.content, 'base64').toString()
      return contents

# NOTE: PRs are issues
issuePostComment = (config, repo, issue, body) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token
  url = "#{config.endpoint}/repos/#{repo}/issues/#{issue}/comments"
  comment =
    body: body
  return axios.post url, comment, request

module.exports.issuePostComment = issuePostComment

graphsFromPR = (config, repo, number) ->
  prGet config, repo, number
  .then (pr) ->
    ret =
      base:
        sha: pr.base.sha
        repo: pr.base.repo.full_name
      head:
        sha: pr.head.sha
        repo: pr.head.repo.full_name
  .then (data) ->
    prGraphsChanged config, repo, number
    .then (graphs) ->
      data.graphsChanged = graphs.map (g) ->
        g.patch = 'hidden'
        return g
      return data
  .then (data) ->
    bluebird.map data.graphsChanged, (graph) ->
      ret =
        filename: graph.filename
      fileAtRevision config, data.head.repo, data.head.sha, graph.filename
      .then (contents) ->
        ret.to = contents
      .then (_) ->
        fileAtRevision config, repo, data.base.sha, graph.filename
        .then (contents) ->
          ret.from = contents
          return ret
      .catch (req) ->
        console.log 'ERROR', req
        ret.error =
          code: req.status
          msg: req.statusText
        return ret

    .then (graphs) ->
      data.graphs = graphs
      return data.graphs

module.exports.graphsFromPR = graphsFromPR

collectStream = (stream) ->
  return new Promise (fufill, reject) ->
    body = ""
    stream.on 'data', (data) ->
      body += data.toString()
    stream.on 'end', () ->
      return fufill body
    stream.on 'error', reject

main = () ->
  [_node, _script, repo, pr] = process.argv

  config =
    endpoint: 'https://api.github.com'
    token: process.env.GH_TOKEN
  throw new Error 'Missing Github PR repo PR' if not (repo and pr)

  collectStream process.stdin
  .then (body) ->
    return issuePostComment config, repo, pr, body
  .then (r) ->
    console.log "Posted comment to #{repo} #{pr}:", r.data.url
  .catch (err) ->
    console.error err

main() if not module.parent

