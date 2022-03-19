# OandaClock

Executes the running Oanda Worker strategies every 30 seconds.

Only the strategies that was started in the Oanda Trader user interface will be executed and paused strategies will be skipped until resumed again from the user interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oanda_clock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oanda_clock

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/oanda_clock.

