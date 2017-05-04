# fbp-diffbot [![Build Status](https://travis-ci.org/flowhub/fbp-diffbot.svg?branch=master)](https://travis-ci.org/flowhub/fbp-diffbot) [![Greenkeeper badge](https://badges.greenkeeper.io/flowhub/fbp-diffbot.svg)](https://greenkeeper.io/)

Automatically posts diffs for FBP graph changes on Github [Pull Requests](https://help.github.com/articles/using-pull-requests/),
using [fbp-diff](https://github.com/flowbased/fbp-diff).
This is useful when doing code reviews, as it makes it easier to understand the changes that were made.

## Status

**Minimally useful**

* Service is live at http://fbp-diffbot.herokuapp.com
* Can follow PR changes in public repos and post diffs as comments
* *Experimental* support for private repos
* Simple HTTP API allows to request checking without requiring webhook integration
* Command-line tool `fbp-diffbot-checkpr` allows checking without using the service

## TODO

See [Github Issues](https://github.com/jonnor/fbp-diffbot/issues)

## Changelog

See [CHANGES.md](./CHANGES.md)

## Using the service

### Adding public repos

[Edit config.yaml](https://github.com/jonnor/fbp-diffbot/edit/master/config.yaml) and submit a pull request.

### Adding private repos

**WARNING: Experimental** [TODO: improve support](https://github.com/jonnor/fbp-diffbot/issues/4)

* 1) Add the `fbp-diffbot` user as a collaborator on the repo, with *READ* access
* 2a) Put your repo into `config.yaml` like with public repo
* 2b) Alternative, send an email to `jononor+fbp-diffbot@gmail.com` with the name of the repository.
It will then be added to the `FBPDIFFBOT_EXTRA_REPOSITORIES` envvar of the deployed service,
so the repository name does not need to be visible in public.

Note that approval is manual, so it *may take a day or two*.

### Manually request PR checking

Endpoint: `POST /checkpr/$owner/$repo/$prnumber`

    curl -X POST http://fbp-diffbot.herokuapp.com/checkpr/$owner/$repo/$prnumber

So for to check [imgflo/imgflo-server#12](https://github.com/imgflo/imgflo-server/pull/12)
would use the URL `http://fbp-diffbot.herokuapp.com/checkpr/imgflo/imgflo-server/12`.

