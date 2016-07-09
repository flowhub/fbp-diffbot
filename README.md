# fbp-diffbot

Automatically posts diffs for FBP graph changes on Github [Pull Requests](https://help.github.com/articles/using-pull-requests/),
using [fbp-diff](https://github.com/flowbased/fbp-diff).
This is useful when doing code reviews, as it makes it easier to understand the change that was made.

## Status

**Proof of concept**

* A command-line tool can get changed graphs from a Github PR and calculate their diffs

## TODO

### v0.1 "minimally useful"

* Posting the diff back to PR
* Register webhooks for automatic update from Github
* Deploy it to production

### Later

* Support visual diffs
