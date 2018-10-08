module NewRelic
  module Manticore
    class WrappedRequestHeaders < Agent::HTTPClients::AbstractRequest
      def initialize(headers)
        @headers = headers || {}
      end

      def [](key)
        _, value = @headers.find { |k, _| k.casecmp(key).zero? }
        value
      end

      def []=(key, value)
        @headers[key] = value
      end

      def host_from_header
        self["Host"]
      end
    end
  end
end
