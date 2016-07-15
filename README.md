# fbp-diffbot

Automatically posts diffs for FBP graph changes on Github [Pull Requests](https://help.github.com/articles/using-pull-requests/),
using [fbp-diff](https://github.com/flowbased/fbp-diff).
This is useful when doing code reviews, as it makes it easier to understand the changes that were made.

## Status

**Proof of concept**

* `fbp-diffbot-checkpr` can check Github PR, calculate diffs and post it as a comment
* Service live at http://fbp-diffbot.herokuapp.com

## Usage

### Manually request PR checking

Endpoint: `POST /checkpr/$owner/$repo/$prnumber`

    curl -X POST http://fbp-diffbot.herokuapp.com/checkpr/$owner/$repo/$prnumber

So for to check [imgflo/imgflo-server#12](https://github.com/imgflo/imgflo-server/pull/12)
would use the URL `http://fbp-diffbot.herokuapp.com/checkpr/imgflo/imgflo-server/12`.
    

## TODO

See [Github Issues](https://github.com/jonnor/fbp-diffbot/issues)
