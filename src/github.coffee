common = require './common'

axios = require 'axios'
bluebird = require 'bluebird'
debug = require('debug')('fbp-diffbot:github')

class HttpError extends Error
  constructor: (msg, code) ->
    @code = code or 500
    @message = msg
    super msg

HttpError.hasErrorCode = (code) ->
  return (err) ->
    return err.code == code

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

  debug 'fetching file', repo, revision, filepath
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
    throw new HttpError "File #{filepath} does not exist in #{revision} of #{repo}", 404 if not foundUrl
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

issueListComments = (config, repo, issue) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token
  url = "#{config.endpoint}/repos/#{repo}/issues/#{issue}/comments"

  return axios.get url, request

exports.issueListComments = issueListComments

prGetChanges = (config, repo, number) ->
  prGet config, repo, number
  .then (pr) ->
    ret =
      base:
        sha: pr.base.sha
        repo: pr.base.repo.full_name
      head:
        sha: pr.head.sha
        repo: pr.head.repo.full_name
    return ret

exports.prGetChanges = prGetChanges

graphsFromPR = (config, repo, number) ->
  
  prGetChanges config, repo, number
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
      bluebird.resolve(fileAtRevision config, data.head.repo, data.head.sha, graph.filename)
      .catch HttpError.hasErrorCode(404), (err) ->
        debug 'to graph not found', graph.filename, data.head.sha
        ret.to = ""
      .then (contents) ->
        ret.to = contents
      .then (_) ->
        bluebird.resolve(fileAtRevision config, repo, data.base.sha, graph.filename)
        .catch HttpError.hasErrorCode(404), (err) ->
          debug 'from graph not found', graph.filename, data.base.sha
          ret.from = ""
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
      return data

exports.graphsFromPR = graphsFromPR

repoAddHook = (config, repo, data) ->
  request =
    headers: {}
  request.headers.Authorization = "token #{config.token}" if config.token
  url = "#{config.endpoint}/repos/#{repo}/hooks"
  return axios.post url, data, request

exports.repoAddHook = repoAddHook

main = () ->
  config = common.getConfig()
  d =
    name: 'web'
    active: true
    config:
      url: config.ownurl+'/hooks/github'
      content_type: 'json'
      'fbp-diffbot-hook-version': 1
    events: ['pull_request']

  repo = 'imgflo/imgflo-server'
  repoAddHook config, repo, d
  .then (r) ->
    console.log 'added webhook', r.data
  .catch (err) ->
    console.error err
    process.exit 2

main() if not module.parent
