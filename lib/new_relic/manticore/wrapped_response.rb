# frozen_string_literal: true

module NewRelic
  module Manticore
    class WrappedResponse
      def initialize(response)
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
