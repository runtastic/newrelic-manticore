# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "minitest/unit"
require "rspec/mocks/minitest_integration"
require "pry"
require "newrelic_rpm"
require "faraday"
require "faraday/adapter/manticore"
require "manticore"
require "new_relic/manticore"

RSpec::Mocks.configuration.verify_partial_doubles = true
