# frozen_string_literal: true

require "new_relic/agent/http_clients/abstract"

module NewRelic
  module Manticore
    class WrappedResponse < NewRelic::Agent::HTTPClients::AbstractResponse
      def initialize(response)
        super(response)
        @headers = response.headers
      end

      def [](key)
        _, value = @headers.find { |k, _| k.casecmp(key).zero? }
        value
      end

      def to_hash
        @headers
      end
    end
  end
end
