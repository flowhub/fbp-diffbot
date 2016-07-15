# fbp-diffbot

Automatically posts diffs for FBP graph changes on Github [Pull Requests](https://help.github.com/articles/using-pull-requests/),
using [fbp-diff](https://github.com/flowbased/fbp-diff).
This is useful when doing code reviews, as it makes it easier to understand the changes that were made.

## Status

**Proof of concept**

* `fbp-diffbot-checkpr` can check Github PR, calculate diffs and post it as a comment

## TODO

### v0.1 "minimally useful"

* Add HTTP API for manually triggering PR check
* Register webhooks for automatic update from Github
* Deploy it to production

### Later

* Perform check/diffing in dedicated worker, using MsgFlo+guv
* Find out how to invalidate/remove outdated comments. Comment onto the diff instead of PR?
* Support visual diffs
* UI for enabling it for a given repo/organization
