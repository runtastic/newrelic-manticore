# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "test/unit"
require "webmock/rspec"

require "newrelic_rpm"
require "manticore"

NewRelic::Agent.require_test_helper
