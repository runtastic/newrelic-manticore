# frozen_string_literal: true

require "new_relic/agent/method_tracer"
require "new_relic/agent/http_clients/abstract_request"

require "new_relic/manticore/wrapped_request_headers"
require "new_relic/manticore/wrapped_response"

module NewRelic
  module Manticore
    # rubocop:disable Metrics/BlockLength
    DependencyDetection.defer do
      @name = :manticore

      depends_on do
        defined?(::Manticore::Client) &&
          !NewRelic::Control.instance["disable_manticore"] &&
          ENV["NEWRELIC_ENABLE"].to_s !~ /false|off|no/i
      end

      executes do
        NewRelic::Agent.logger.info "Installing Manticore Instrumentation"
      end

      executes do
        require "new_relic/agent/external"

        ::Manticore::Client.class_eval do
          def request_with_newrelic_trace(*args, &blk)
            segment = create_newrelic_segment(*args)

            segment.add_request_headers(WrappedRequestHeaders.new(args[2][:headers]))
            request_without_newrelic_trace(*args, &blk).tap do |response|
              segment.read_response_headers(WrappedResponse.new(response))
            end
          ensure
            segment.finish if segment
          end

          alias_method :request_without_newrelic_trace, :request
          alias_method :request, :request_with_newrelic_trace

          def create_newrelic_segment(*args)
            NewRelic::Agent::External.start_segment(
              library: "Manticore",
              uri: args[1],
              procedure: args[0].new.method
            ).tap do |segment|
              segment.record_metrics = false if segment.parent.is_a?(::NewRelic::Agent::Transaction::DatastoreSegment)
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
