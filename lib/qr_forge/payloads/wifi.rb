# frozen_string_literal: true

module QrForge
  module Payloads
    # Represents a Wi-Fi network payload
    # @example returns WIFI:T:<encryption>;S:<ssid>;P:<password>;H:<hidden>;;
    class Wifi
      VALID_ENCRYPTIONS = %w[WEP WPA WPA2 WPA3].freeze
      NO_PASSWORD_ENCRYPTION = "NOPASS"

      def initialize(encryption:, ssid:, password: nil, hidden: false)
        @encryption = encryption.upcase
        @ssid = ssid
        @password = password
        @hidden = hidden
      end

      #
      # Encryption type for the Wi-Fi network.
      # @return [String, nil] The encryption type or nil if no password is set.
      def encryption_type
        "T:#{@encryption}" unless @encryption == NO_PASSWORD_ENCRYPTION
      end

      #
      # SSID of the Wi-Fi network.
      # @return [String] The SSID
      def ssid
        "S:#{escape(@ssid)}"
      end

      #
      # Password for the Wi-Fi network.
      # @return [String, nil] The password or nil if no password is set.
      def password
        "P:#{escape(@password)}" if @password && @encryption != NO_PASSWORD_ENCRYPTION
      end

      #
      # Indicates if the Wi-Fi network is hidden
      # @return [String, nil] "H:true" if hidden, nil otherwise
      def hidden
        "H:true" unless @hidden.nil? || @hidden == false
      end

      #
      # Returns the parts of the Wi-Fi payload as an array.
      # @return [Array<String>] The parts of the Wi-Fi payload
      def parts
        parts = []
        parts << ssid
        parts << encryption_type
        parts << password
        parts << hidden

        parts.compact
      end

      def to_s
        "WIFI:#{parts.join(";")};;"
      end

      #
      # Validates the Wi-Fi payload data.
      # @raise [PayloadValidationError] if the SSID is blank or if the password is required but not provided.
      # @raise [PayloadValidationError] if the encryption type is invalid.
      def validate!
        raise PayloadValidationError, "SSID is required" if blank?(@ssid)

        if @encryption != NO_PASSWORD_ENCRYPTION && blank?(@password)
          raise PayloadValidationError, "Password is required for #{@encryption} networks"
        end

        return if VALID_ENCRYPTIONS.include?(@encryption) || @encryption == NO_PASSWORD_ENCRYPTION

        raise PayloadValidationError, "Invalid encryption: #{@encryption}"
      end

      private

      #
      # Escapes special characters in the Wi-Fi payload.
      # @param str [String, NilClass] The string to escape
      # @return [String] The escaped string
      def escape(str)
        return "" if blank?(str)

        # https://github.com/zxing/zxing/wiki/Barcode-Contents#wi-fi-network-config-android-ios-11
        # Escape characters: \ ; , : " as they are valid in SSID but are used as delimiters in the payload format
        str.to_s.gsub(/([\\;,:"])/) { "\\#{::Regexp.last_match(1)}" }
      end

      #
      # Checks if a value is blank.
      # @param val [String, nil] The value to check
      # @return [Boolean] true if the value is blank, false otherwise
      def blank?(val)
        val.nil? || val.strip == ""
      end
    end
  end
end
