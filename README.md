# BetterHeroku

[![Gem Version](https://badge.fury.io/rb/better_heroku.svg)](http://badge.fury.io/rb/better_heroku)

<!-- Tocer[start]: Auto-generated, don't remove. -->

# Table of Contents

- [Features](#features)
- [Screencasts](#screencasts)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
- [Tests](#tests)
- [Versioning](#versioning)
- [Code of Conduct](#code-of-conduct)
- [Contributions](#contributions)
- [License](#license)
- [History](#history)
- [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

# Features

**BetterHeroku** Is a better Heroku client gem. The official "platform-api"
Heroku client gem has several issues:

 * The name itself is presumptuous. No mention of Heroku, assumes there's no
   other platform for which there's an API.
 * The code is auto-generated from a `schema.json` provided by Heroku
   themselves. The gem is not updated nearly as
   frequently as the `schema.json`, and lags behind the published APIs.
 * The `schema.json` itself often lags behind the published API docs, and
   occasionally disagrees with them.
 * It's not obvious how to consume the documented API.
   * The way to get the [current account][heroku-account-info] is
     `heroku.account.info("~")`. The only way to know this
     is to contact Heroku support.
   * For a url with multiple parameters, like [info for a dyno for an app][heroku-dyno-info],
     is requested like `heroku.dyno.info(app, dyno)`.
     The parameters are not documented, because the code is generated.
 * The client provides no access to the lower-level HTTP client, Excon, to
   enable features such as HTTP persistence, or to override it for testing.
 * The client provides no means to add logging or instrumentation of the raw
   requests.

**BetterHeroku** attempts to solve all these problems by being a much simpler
and less-opinionated implementation.

[heroku-account-info]: https://devcenter.heroku.com/articles/platform-api-reference#account
[heroku-dyno-info]:    https://devcenter.heroku.com/articles/platform-api-reference#dyno-info

# Requirements

0. [Ruby 2.4.0](https://www.ruby-lang.org)

# Setup

    gem install better_heroku

Add the following to your Gemfile:

    gem "better_heroku"

# Usage

```ruby
client = BetterHeroku::Client.new.authenticate(token: my_token)
resp = client.get("apps", app_id)
resp.status #=> 200
resp["id"]  #=> "01234567-89ab-cdef-0123-456789abcdef"
```

The client pays no attention to the segments of the url passed in, and instead
just joins them with `/`. This way, it always matches 1:1 with the published
API docs. In this example, we're using the [App Info][heroku-app-info]
endpoint, which looks like `GET /apps/{app_id_or_name}` in the docs. Just pass
in the various segments in the same order, and it'll work.

[heroku-app-info]: https://devcenter.heroku.com/articles/platform-api-reference#app-info

## Authentication

**BetterHeroku** supports all the Heroku methods of authentication.

### Personal API tokens

Get your personal API token from the Heroku dashboard, or from the CLI:

    heroku auth:token

You'll get a UUID that you can use to make requests:

```ruby
client = BetterHeroku::Client.new.authenticate(token: "01234567-89ab-cdef-0123-456789abcdef")
resp = client.get("apps", app_id)
```

In one-off scripts this is fine, but for production usage I strongly recommend
you put the token in a config or environment variable.

### OAuth tokens

When making requests on behalf of other users, you'll need to use OAuth tokens.
See the [Heroku OAuth docs][heroku-oauth-docs] for details.

Once set up, you'll have your Heroku OAuth secret. In this example, we've
stored it in an environment variable called `HEROKU_OAUTH_SECRET`. Once your
users go through the web flow, you'll get back from Heroku a `token` and a
`refresh_token`. The `token` expires after 8 hours, and the `refresh_token`
never expires, and may be used to obtain a new token.

If you're not concerned about storing the token (perhaps you only make a few
requests once a day, and the token would have expired the next time you need it
anyways), you can just authenticate with your secret and the refresh token:

```ruby
client = BetterHeroku::Client.new
authenticated_client = client.oauth(secret: ENV["HEROKU_OAUTH_SECRET"], refresh_token: refresh_token)

resp = authenticated_client.get("apps", app_id)
```

The `authenticated_client` will not automatically handle refreshing the oauth
token, however it does provide a simple facility to do so via
`#refresh_oauth_token`. Additionally, that method takes an optional callback
that can be used to persist the access token for future requests.

As **BetterHeroku** borrow's HTTP.rb's philosophy of a immutable client object,
you'll need to replace the client you're using with the refreshed client
object. If you're using threads, its on you to handle handle that in a
threadsafe manner. In most cases, doing so probably isn't necessary, the
following example should work fine.

```ruby
response = authenticated_client.get("apps", app_id)
if response.status == 401
  refreshed_client = authenticated_client.refresh_oauth_token do |response|
    user.update_attribute(:oauth_token, response["access_token"])
  end
  response = refreshed_client.get("apps", app_id)
end
```

The `response` is the response body as documented in the [Heroku OAuth token
refresh docs][heroku-token-refresh-docs].

[heroku-oauth-docs]: https://devcenter.heroku.com/articles/oauth
[heroku-token-refresh-docs]: https://devcenter.heroku.com/articles/oauth#token-refresh

## Mocking requests

You probably don't want to always make actual requests against the Heroku API,
so **BetterHeroku** provides a mechanism to pass in the lower HTTP client. An
example of what this might look like:

```ruby
let(:http) { double(HTTP) }

it "should do awesome things" do
  allow(http).to receive(:get).and_return(BetterHeroku::MockResponse.new({"id" => "01234567-89ab-cdef-0123-456789abcdef"})
  client = BetterHeroku::Client.new(http: http)

  resp = client.get("accounts", "01234567-89ab-cdef-0123-456789abcdef")

  expect(resp["id"]).to eq "01234567-89ab-cdef-0123-456789abcdef"
end
```

Also, be sure to check out the [FakeHTTP][fake-http] gem to mock the HTTP
library with a Sinatra-like DSL.

[fake-http]: https://github.com/paul/fake_http

# Tests

To test, run:

    rake

# Versioning

Read [Semantic Versioning](http://semver.org) for details. Briefly, it means:

- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Major (X.y.z) - Incremented for any backwards incompatible public API changes.

# Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

# Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

# License

Copyright (c) 2017 [Paul Sadauskas](mailto:psadauskas@gmail.com).
Read [LICENSE](LICENSE.md) for details.

# History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

# Credits

Developed by [Paul Sadauskas](mailto:psadauskas@gmail.com)
