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
