# fbp-diffbot

Automatically posts diffs for FBP graph changes on Github [Pull Requests](https://help.github.com/articles/using-pull-requests/),
using [fbp-diff](https://github.com/flowbased/fbp-diff).
This is useful when doing code reviews, as it makes it easier to understand the changes that were made.

## Status

**Proof of concept**

* A command-line tool can get changed graphs from a Github PR and calculate their diffs

## TODO

### v0.1 "minimally useful"

* Posting the diff back to PR
* Register webhooks for automatic update from Github
* Find out how to invalidate outdated comments. Post onto the diff?
* Find out how to avoid duplicate comments
* Deploy it to production

### Later

* Support visual diffs
* UI for enabling it for a given repo/organization
