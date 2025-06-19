# frozen_string_literal: true

require "uri"

module QrForge
  module Payloads
    #
    # Represents a URL payload
    # @example return "https://example.com" or "http://example.com"
    class Url
      def initialize(url)
        @url = url
      end

      def to_s
        @url
      end

      #
      # Validates that the passed url is a valid HTTP or HTTPS URL.
      def validate!
        uri = URI.parse(@url)

        unless uri.is_a?(::URI::HTTP) || uri.is_a?(::URI::HTTPS)
          raise PayloadValidationError, "Must be a valid HTTP/HTTPS URL"
        end
      rescue ::URI::InvalidURIError
        raise PayloadValidationError, "Invalid URL syntax"
      end
    end
  end
end
