github = require './github'
common = require './common'

bluebird = require 'bluebird'
debug = require('debug')('fbp-diffbot:webhooks')

versionKey = 'fbp-diffbot-hook-version'
currentVersion = "1" # note: string, cause github API autoconvers ints

ensureRepoHook = (config, repo) ->

  # TODO: check that webhook status is good
  # TODO: handle case where webhook config exists, but needs changes
  github.repoListHooks config, repo
  .then (res) ->
    matches = res.data.filter (h) ->
      return h.config[versionKey] == currentVersion
    debug 'WARN: multiple matching hooks', matches.length, repo if matches.length > 1
    needsAdding = (matches.length == 0)
    return Promise.resolve needsAdding
  .then (addNew) ->
    newHook =
      name: 'web'
      active: true
      events: ['pull_request']
      config:
        url: config.ownurl+'/hooks/github'
        content_type: 'json'
    newHook.config[versionKey] = currentVersion

    if addNew
      return github.repoAddHook config, repo, newHook
    else
      return Promise.resolve null

ensureRepositoryHooks = (config) ->
  bluebird.map config.repositories, (repo) ->
    return ensureRepoHook config, repo
  .then (results) ->
    added = results.filter (r) -> r?
    return Promise.resolve added

exports.ensureRepositoryHooks = ensureRepositoryHooks

main = () ->
  config = common.getConfig {}

  ensureRepositoryHooks config
  .then (added) ->
    for add in added
      console.log 'added webhook', add.data.url
    if not added.length
      console.log 'no webhook additions needed'
  .catch (err) ->
    console.error err
    process.exit 2

main() if not module.parent
