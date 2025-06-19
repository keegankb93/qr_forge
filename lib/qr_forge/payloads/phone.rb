# frozen_string_literal: true

module QrForge
  module Payloads
    #
    # Represents a telephone payload
    # @example return "https://example.com" or "http://example.com"
    class Phone
      def initialize(phone_number)
        @phone_number = phone_number
      end

      def to_s
        "tel:#{@phone_number}"
      end

      #
      # Validates that the passed phone number is in a valid format.
      # @example
      #   valid phones:
      #     +919367788755
      #     8989829304
      #     +16308520397
      #     786-307-3615
      #     555.555.5555
      def validate!
        # credit: https://ihateregex.io/expr/phone/
        return if @phone_number =~ /^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$/

        raise PayloadValidationError, "Invalid phone number format"
      end
    end
  end
end
