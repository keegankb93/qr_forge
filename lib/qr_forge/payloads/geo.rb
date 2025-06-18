# frozen_string_literal: true

puts "[Geo] file loaded"

module QrForge
  module Payloads
    #
    # Represents a geo lat/long payload
    # @example return "geo:40.712776,-74.005974"
    class Geo
      def initialize(latitude:, longitude:)
        @latitude = latitude
        @longitude = longitude
      end

      def to_s
        "geo:#{@latitude},#{@longitude}"
      end

      #
      # Validates that the passed latitude and longitude are within valid ranges.
      def validate!
        return if (-90..90).cover?(@latitude.to_f) && (-180..180).cover?(@longitude.to_f)

        raise PayloadValidationError, "Latitude or longitude out of range"
      end
    end
  end
end
