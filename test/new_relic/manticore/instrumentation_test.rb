# frozen_string_literal: true

require "./test/test_helper"

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
        it "does not deduct manticore time from exclusive database time" do
          client = ::Manticore::Client.new
          expect(client.client).to receive(:execute).and_wrap_original do |original, *args|
            sleep(1)
            original.call(*args)
          end

          in_transaction do
            NewRelic::Agent::Datastores.wrap("Elasticsearch", "Search", "index_name") do
              client.post(request_uri, body: "data").body
            end
          end

          db_metric = "Datastore/operation/Elasticsearch/Search"
          database_spec = metric_spec_from_specish(db_metric)
          exclusive_time = NewRelic::Agent.instance.stats_engine.to_h[database_spec].total_exclusive_time

          assert_operator(exclusive_time, :>, 1.0)

          assert_metrics_recorded(db_metric => { call_count: 1 })
        end

        describe "when the last segment before the manticore segment is a finished database segment" do
          it "does create an external request segment" do
            in_transaction do
              NewRelic::Agent::Datastores.wrap("Elasticsearch", "Search", "index_name") do
                sleep(0.01)
              end
              ::Manticore.post(request_uri, body: "data").body
            end

            assert_metrics_recorded("External/#{external_service}/Manticore/POST" => { call_count: 1 })
          end
        end
      end

      describe "with cross app tracking disabled" do
        let(:config) do
          {
            "cross_application_tracer.enabled": false,
            "distributed_tracing.enabled":      true,
            "cross_process_id":                 "1",
            "encoding_key":                     "utf8"
          }
        end

        it "adds newrelic tracking headers" do
          with_config(config) do
            in_transaction do |_transaction|
              response = ::Manticore.post(request_uri, body: "data", headers: { "foo" => "bar" })
              response.body

              assert_includes(response.request.headers.keys, "newrelic")
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
