[travis]: https://travis-ci.org/runtastic/newrelic-manticore
[rubygems]: https://rubygems.org/gems/newrelic-manticore
[manticore]: https://gitlab.com/cheald/manticore
[mit]: http://opensource.org/licenses/MIT
[cc]: http://contributor-covenant.org

# NewrelicManticore

[![Build Status](https://travis-ci.org/runtastic/newrelic-manticore.svg?branch=master)][travis]
[![Gem Version](https://badge.fury.io/rb/newrelic-manticore.svg)][rubygems]
[![codecov](https://codecov.io/gh/runtastic/newrelic-manticore/branch/master/graph/badge.svg)](https://codecov.io/gh/runtastic/newrelic-manticore)

Adds NewRelic instrumentation for the [Manticore JRuby HTTP client][manticore].

## Installation
Add this line to your application's Gemfile:

`$ gem 'newrelic-manticore'`

And then execute:

`$ bundle`

## How it works
When `newrelic/manticore` is required (e.g. automatically by Bundler), the gem becomes active.
It hooks itself into `Manticore::Client#request` and traces your HTTP calls as external requests,
adding also the necessary headers for cross application tracing.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/runtastic/newrelic-manticore.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant code of conduct][cc].

## License
The gem is available as open source under [the terms of the MIT License][mit].
