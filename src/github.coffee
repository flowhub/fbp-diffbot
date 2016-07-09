
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
      getAuthenticated config, graph.raw_url
      .then (req) ->
        ret.to = req.data
      .then (_) ->
        ret.from = null # FIXME: implement
        return ret
      .catch (req) ->
        # FIXME: figure out why fails for private repos
        ret.error =
          code: req.status
          msg: req.statusText
        return ret

    .then (graphs) ->
      data.graphs = graphs
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
