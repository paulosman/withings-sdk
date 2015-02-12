# Withings API Ruby Gem

This gem provides access to data collected by [Withings](http://withings.com/) devices through their [HTTP API](https://oauth.withings.com/api/doc).

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

Before you can make requests to the Withings API, you must obtain an OAuth access token.

```ruby
client = Withings::Client.new do |config|
  config.consumer_key    = 'YOUR_CONSUMER_KEY'
  config.consumer_secret = 'YOUR_CONSUMER_SECRET'
  config.callback_url    = 'YOUR_CALLBACK_URL'
end
```

The id of the authenticated user will be provided in the query string of the request made to
your callback URL.

```ruby
client.set_user_id(user_id)
```

Now you can make authenticated requests on behalf of a user. For example, to get a list of
activity measures, you can use the following example:

```ruby
activities = client.activity_measures
activities.each do |activity|
  if activity.is_a?(Withings::ActivityMeasure)
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
