# fbp-diffbot

Automatically posts diffs for FBP graph changes on Github [Pull Requests](https://help.github.com/articles/using-pull-requests/),
using [fbp-diff](https://github.com/flowbased/fbp-diff).
This is useful when doing code reviews, as it makes it easier to understand the changes that were made.

## Status

**Minimally useful**

* Service is live at http://fbp-diffbot.herokuapp.com
* Can follow PR changes in public repos and post diffs as comments
* Simple HTTP API allows to request checking without
* Command-line tool `fbp-diffbot-checkpr` allows checking without using the service

## TODO

See [Github Issues](https://github.com/jonnor/fbp-diffbot/issues)

## Using the service

### Adding public repos

[Edit config.yaml](https://github.com/jonnor/fbp-diffbot/edit/master/config.yaml) and submit a pull request.

### Adding private repos

[TODO: improve support](https://github.com/jonnor/fbp-diffbot/issues/4)

### Manually request PR checking

Endpoint: `POST /checkpr/$owner/$repo/$prnumber`

    curl -X POST http://fbp-diffbot.herokuapp.com/checkpr/$owner/$repo/$prnumber

So for to check [imgflo/imgflo-server#12](https://github.com/imgflo/imgflo-server/pull/12)
would use the URL `http://fbp-diffbot.herokuapp.com/checkpr/imgflo/imgflo-server/12`.

