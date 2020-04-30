# frozen_string_literal: true

# Check version to account for a breaking path change
# introduced in 6.10
#
if NewRelic::VERSION::MAJOR == 6 && NewRelic::VERSION::MINOR < 10
  require "new_relic/agent/http_clients/abstract_request"
else
  require "new_relic/agent/http_clients/abstract"
end

module NewRelic
  module Manticore
    class WrappedRequest < Agent::HTTPClients::AbstractRequest
      def initialize(request)
        @request = request
      end

      def [](key)
        _, value = @request.headers.find { |k, _| k.casecmp(key).zero? }
        value
      end

      def []=(key, value)
        @request.set_header(key, value)
      end

      def host_from_header
        self["Host"]
      end
    end
  end
end
