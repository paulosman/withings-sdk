# Withings API Ruby Gem

[![Build Status](http://img.shields.io/travis/paulosman/withings.svg)][travis]
[![Code Climate](https://codeclimate.com/github/paulosman/withings/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/paulosman/withings/badges/coverage.svg)][coverage]
[![Dependency Status](https://gemnasium.com/paulosman/withings.svg)][gemnasium]

This gem provides access to data collected by [Withings](http://withings.com/) devices through
their [HTTP API](https://oauth.withings.com/api/doc).

NOTE: This gem is a work in progress. It is not yet available via RubyGems.

[travis]: https://travis-ci.org/paulosman/withings
[codeclimate]: https://codeclimate.com/github/paulosman/withings
[coverage]: https://codeclimate.com/github/paulosman/withings
[gemnasium]: https://gemnasium.com/paulosman/withings

### TODO

* Notifications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'withings'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install withings

## Usage

### Authorization

Withings uses OAuth 1.0a for API authorization. If you're unfamiliar with OAuth, you can
[read about it here][bible] or you can [read the full spec][spec] if you're feeling brave.

Before you can make requests to the Withings API, you must first obtain user authorization and
generate an Access Token. Before you can write an application that uses the Withings API you
must [register and obtain consumer credentials][register].

The following examples assume you are using a web framework such as [Sinatra][sinatra].

[register]: https://oauth.withings.com/partner/add "Withings Application Registration"
[bible]: http://oauthbible.com/ "OAuth Bible"
[spec]: http://oauth.net/core/1.0a/ "OAuth 1.0a Core Spec"
[sinatra]: http://www.sinatrarb.com/ "Sinatra"

```ruby
client = Withings::Client.new({
  consumer_key: 'YOUR_CONSUMER_KEY',
  consumer_secret: 'YOUR_CONSUMER_SECRET'
})

request_token = client.request_token({
  oauth_callback: 'YOUR_OAUTH_CALLBACK'
})

authorize_url = client.authorize_url(request_token.token, request_token.secret)
redirect authorize_url
```

When the user has finished authorizing your application, they will be redirected
to the callback URL you specified with the following parameters in the query string:
```userid```, ```oauth_token``` and ```oauth_verifier```. Store these parameters as
you'll need them later.

```ruby
client = Withings::Client.new({
  consumer_key: 'YOUR_CONSUMER_KEY',
  consumer_secret: 'YOUR_CONSUMER_SECRET'
})

client.access_token(request_token.token, request_token.secret, {
  oauth_verifier: 'OAUTH_VERIFIER'
})
```

## Making Requests

Now that you have an authorized access token, you can create a ```Withings::Client``` instance:

```ruby
client = Withings::Client.new do |config|
  config.consumer_key        = 'YOUR_CONSUMER_KEY'
  config.consumer_secret     = 'YOUR_CONSUMER_SECRET'
  config.token               = 'YOUR_ACCESS_TOKEN'
  config.secret              = 'YOUR_ACCESS_TOKEN_SECRET'
end
```

Now you can make authenticated requests on behalf of a user. For example, to get a list of
activity measures, you can use the following example:

```ruby
activities = client.activities(user_id, { startdateymd: '2015-01-01', enddateymd: '2015-02-28' })
activities.each do |activity|
  if activity.is_a?(Withings::Activity)
    puts "Date: #{activity.date}, Steps: #{activity.steps}"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/paulosman/withings/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
