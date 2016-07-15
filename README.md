# fbp-diffbot

Automatically posts diffs for FBP graph changes on Github [Pull Requests](https://help.github.com/articles/using-pull-requests/),
using [fbp-diff](https://github.com/flowbased/fbp-diff).
This is useful when doing code reviews, as it makes it easier to understand the changes that were made.

## Status

**Proof of concept**

* A command-line tool can get changed graphs from a Github PR and calculate their diffs

## TODO

### v0.1 "minimally useful"

* Avoid duplicate comments
* Add HTTP API for manually triggering PR check
* Register webhooks for automatic update from Github
* Deploy it to production

### Later

* Perform check/diffing in dedicated worker, using MsgFlo+guv
* Find out how to invalidate/remove outdated comments. Comment onto the diff instead of PR?
* Support visual diffs
* UI for enabling it for a given repo/organization
