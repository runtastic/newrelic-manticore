# frozen_string_literal: true

require "ostruct"

require "new_relic/agent/method_tracer"

require "new_relic/manticore/wrapped_request"
require "new_relic/manticore/wrapped_response"

module NewRelic
  module Manticore
    # We do not want to create a segment if there is no newrelic
    # transaction or if we are inside a database segment.
    #
    # An external call segment inside a database segment would
    # deduct the time needed in manticore from the database call,
    # which we want to be the total time needed for the database
    # operation
    def self.create_segment?
      state = NewRelic::Agent::TransactionState.tl_get
      return false unless state&.current_transaction

      return true unless state.current_transaction.current_segment

      !state.current_transaction.current_segment.is_a?(
        ::NewRelic::Agent::Transaction::DatastoreSegment
      )
    end

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
        PARALLEL_REQUEST_DUMMY = OpenStruct.new(
          host_from_header: "<MultipleHosts>"
        )

        ::Manticore::Client.class_eval do
          # This is called for parallel requests that are executed in
          # a batch
          #
          # rubocop:disable Metrics/MethodLength
          def execute_with_newrelic_trace!
            if NewRelic::Manticore.create_segment?
              req = []
              req << @async_requests.pop until @async_requests.empty?
              req.each do |r|
                @async_requests.push(r)
              end

              segment = NewRelic::Agent::Tracer.start_external_request_segment(
                library:   "Manticore",
                uri:       req.first.request.uri.to_s,
                procedure: "Parallel batch"
              )
              segment.add_request_headers(PARALLEL_REQUEST_DUMMY)
            end
            execute_without_newrelic_trace!
          ensure
            segment.finish if defined?(segment) && segment
          end
          # rubocop:enable Metrics/MethodLength

          alias_method :execute_without_newrelic_trace!, :execute!
          alias_method :execute!, :execute_with_newrelic_trace!
        end

        ::Manticore::Response.class_eval do
          # This is called for every request, also parallel and async
          # requests.
          #
          # rubocop:disable Metrics/MethodLength
          def call_with_newrelic_trace
            if NewRelic::Manticore.create_segment?
              segment = create_newrelic_segment
              segment.add_request_headers(WrappedRequest.new(@request))
              on_complete do |response|
                begin
                  segment.process_response_headers(WrappedResponse.new(response))
                ensure
                  segment.finish
                end
              end
            end
            call_without_newrelic_trace
          rescue StandardError => e
            segment.finish if defined?(segment) && segment
            raise e
          end
          # rubocop:enable Metrics/MethodLength

          alias_method :call_without_newrelic_trace, :call
          alias_method :call, :call_with_newrelic_trace

          def create_newrelic_segment
            NewRelic::Agent::Tracer.start_external_request_segment(
              library:   "Manticore",
              uri:       @request.uri.to_s,
              procedure: @request.method
            )
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
