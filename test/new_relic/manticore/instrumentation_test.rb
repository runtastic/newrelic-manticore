# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "minitest/unit"
require "rspec/mocks/minitest_integration"
require "newrelic_rpm"
require "faraday"
require "faraday/adapter/manticore"
require "manticore"
require "new_relic/manticore"
require "pry"

NewRelic::Agent.require_test_helper
DependencyDetection.detect!

module NewRelic
  module Manticore
    class InstrumentationTest < Minitest::Test
      extend Minitest::Spec::DSL

      let(:external_service) { "www.google.com" }
      let(:request_uri) { "https://#{external_service}" }

      before do
        NewRelic::Agent.manual_start
        clear_metrics!
      end

      it "works without a transaction" do
        ::Manticore.get(request_uri).body
      end

      it "instruments GET requests" do
        in_transaction { ::Manticore.get(request_uri).body }
        assert_metrics_recorded("External/#{external_service}/Manticore/GET" => { call_count: 1 })
      end

      it "instruments POST requests" do
        in_transaction { ::Manticore.post(request_uri, body: "data").body }
        assert_metrics_recorded("External/#{external_service}/Manticore/POST" => { call_count: 1 })
      end

      describe "with parallel manticore requests" do
        it "tracks two segments" do
          in_transaction do
            client = ::Manticore::Client.new
            response1 = client.parallel.get("http://google.com")
            response2 = client.parallel.get("http://yahoo.com")

            success_count = 0
            response1.on_success { |_response| success_count += 1 }
            response2.on_success { |_response| success_count += 1 }
            client.execute!

            assert(success_count, 2)
          end

          assert_metrics_recorded("External/<MultipleHosts>/Manticore/Parallel batch" => { call_count: 1 })
        end

        it "does not create an external request segments" do
          expect(NewRelic::Agent::External).not_to receive(:start_segment)

          in_transaction do
            NewRelic::Agent::Datastores.wrap("Elasticsearch", "Search", "index_name") do
              client = ::Manticore::Client.new
              client.parallel.get("http://google.com")
              client.parallel.get("http://yahoo.com")
              client.execute!
            end
          end

          assert_metrics_recorded("Datastore/operation/Elasticsearch/Search" => { call_count: 1 })
        end
      end

      describe "with async manticore requests" do
        it "tracks a segment" do
          in_transaction do
            client = ::Manticore::Client.new
            request = client.background.get("http://google.com")
            future = request.call
            future.get
          end

          assert_metrics_recorded("External/google.com/Manticore/GET" => { call_count: 1 })
        end
      end

      describe "a request made with faraday" do
        it "instruments the request" do
          in_transaction do
            Faraday
              .new { |f| f.adapter :manticore }
              .get(request_uri).body
          end
          assert_metrics_recorded("External/#{external_service}/Manticore/GET" => { call_count: 1 })
        end
      end

      describe "when manticore is used as transport for a database (e.g. in Elasticsearch)" do
        it "does not create an external request segment" do
          expect(NewRelic::Agent::External).not_to receive(:start_segment)

          in_transaction do
            NewRelic::Agent::Datastores.wrap("Elasticsearch", "Search", "index_name") do
              ::Manticore.post(request_uri, body: "data").body
            end
          end

          assert_metrics_recorded("Datastore/operation/Elasticsearch/Search" => { call_count: 1 })
        end
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
          with_config(config) do
            in_transaction do |_transaction|
              response = ::Manticore.post(request_uri, body: "data", headers: { "foo" => "bar" })
              response.body

              assert_includes(response.request.headers.keys, "X-NewRelic-ID")
              assert_includes(response.request.headers.keys, "X-NewRelic-Transaction")
              assert_includes(response.request.headers.keys, "foo")
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
