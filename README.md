# Newrelic-Manticore

[![Build Status](https://travis-ci.org/runtastic/newrelic-manticore.svg?branch=master)][travis]
[![Gem Version](https://badge.fury.io/rb/newrelic-manticore.svg)][rubygems]

Adds NewRelic instrumentation for the [Manticore JRuby HTTP client][manticore].

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'newrelic-manticore'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install newrelic-manticore

## Usage

When `newrelic/manticore` is required (e.g. automatically by Bundler), the gem becomes active.
It wraps `Manticore::Response#call` and traces your HTTP calls as external requests,
adding also the necessary headers for cross application tracing.

### What about parallel requests?
The NewRelic agent is currently not set up to support multithreaded requests. As [any of the other client integrations](https://docs.newrelic.com/docs/agents/ruby-agent/features/http-client-tracing-ruby#typhoeus),
_newrelic-manticore_ will trace all parallel requests as [one external service call](https://github.com/runtastic/newrelic-manticore/blob/master/test/new_relic/manticore/instrumentation_test.rb#L50).

### What about async "background" requests?
Those are traced normally as any other request would be.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/runtastic/newrelic-manticore.
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [code of conduct][cc].

## License
The gem is available as open source under [the terms of the MIT License][mit].

[travis]: https://travis-ci.org/runtastic/newrelic-manticore
[rubygems]: https://rubygems.org/gems/newrelic-manticore
[manticore]: https://gitlab.com/cheald/manticore
[mit]: http://opensource.org/licenses/MIT
[cc]: ../CODE_OF_CONDUCT.md
