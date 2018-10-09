# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "minitest/unit"
require "webmock/minitest"
require "newrelic_rpm"
require "manticore"
require "new_relic/manticore"

NewRelic::Agent.require_test_helper
DependencyDetection.detect!

module NewRelic
  module Manticore
    class InstrumentationTest < Minitest::Unit::TestCase
      extend Minitest::Spec::DSL

      let(:external_service) { "www.google.com" }
      let(:request_uri) { "https://#{external_service}" }

      before do
        stub_request(:any, /169.254.169.254/)          # Disable AWS instance identity check
        stub_request(:any, /metadata.google.internal/) # Disable Google cloud instance identity check
        stub_request(:any, /collector.newrelic.com/)
        stub_request(:any, /#{request_uri}/)
        NewRelic::Agent.manual_start
      end

      it "instruments GET requests" do
        in_transaction { ::Manticore.get(request_uri, query: { q: "kittens" }) }
        assert_metrics_recorded("External/#{external_service}/Manticore/GET" => { call_count: 1 })
      end

      it "instruments POST requests" do
        in_transaction { ::Manticore.post(request_uri, body: "data") }
        assert_metrics_recorded("External/#{external_service}/Manticore/POST" => { call_count: 1 })
      end
    end
  end
end
