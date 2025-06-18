# frozen_string_literal: true

module QrForge
  module Payloads
    #
    # Represents a plain text payload
    # @example return "Hello, World!"
    class PlainText
      def initialize(text)
        @text = text
      end

      def to_s
        @text
      end

      #
      # Validates that the passed data is a string.
      def validate!
        raise PayloadValidationError, "Must be a valid string" unless @text.is_a?(String)
        raise PayloadValidationError, "String cannot be empty" if @text.empty?
      end
    end
  end
end
