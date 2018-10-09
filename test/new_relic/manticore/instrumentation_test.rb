# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "minitest/unit"
require "rspec/mocks/minitest_integration"
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
        clear_metrics!
      end

      it "instruments GET requests" do
        in_transaction { ::Manticore.get(request_uri, query: { q: "kittens" }) }
        assert_metrics_recorded("External/#{external_service}/Manticore/GET" => { call_count: 1 })
      end

      it "instruments POST requests" do
        in_transaction { ::Manticore.post(request_uri, body: "data") }
        assert_metrics_recorded("External/#{external_service}/Manticore/POST" => { call_count: 1 })
      end

      describe "with cross app tracking enabled" do
        let(:config) do
          {
            "cross_application_tracer.enabled": true,
            "distributed_tracing.enabled": false,
            "cross_process_id": "1",
            "encoding_key": "utf8"
          }
        end

        it "adds newrelic tracking headers" do
          stub_request(:any, /#{request_uri}/).with(
            headers: { "X-Newrelic-Id": /./, "Foo": /./ }
          )

          with_config(config) do
            in_transaction do |_transaction|
              ::Manticore.post(request_uri, body: "data", headers: { "foo" => "bar" })
            end
          end
        end

        it "no error occurs during reading or writing headers" do
          expect(NewRelic::Agent.logger).not_to receive(:error)
            .with(/add_request_headers/, anything)
          expect(NewRelic::Agent.logger).not_to receive(:error)
            .with(/read_response_headers/, anything)

          with_config(config) do
            in_transaction do |_transaction|
              ::Manticore.post(request_uri, body: "data")
            end
          end
        end
      end
    end
  end
end
