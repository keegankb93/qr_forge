# frozen_string_literal: true

module QrForge
  #
  # Payload is a factory class that builds different types of payloads based on the provided type and data.
  # It will validate the payload data (based on the type) and return a string representation of the payload.
  class Payload

    # TODO: Add passkey and sms support
    PAYLOAD_TYPES = {
      wifi: ::QrForge::Payloads::Wifi,
      plain: ::QrForge::Payloads::PlainText,
      url: ::QrForge::Payloads::Url,
      geo: ::QrForge::Payloads::Geo,
      phone: ::QrForge::Payloads::Phone
    }.freeze

    #
    # Builds a payload based on the type and data provided.
    # @param type [Symbol] The type of payload to build (e.g., :url, :wifi).
    # @param data [String, Hash] The data to encode in the payload.
    # @return [String] The string representation of the payload.
    def self.build(type:, data:)
      klass = PAYLOAD_TYPES[type.to_sym]

      raise ArgumentError "Invalid payload type: #{type}" unless klass

      payload = case data
                when Hash
                  klass.new(**data)
                when String
                  klass.new(data)
                else
                  raise ArgumentError, "Invalid data type: #{data.class}. Expected Hash or String."
                end

      payload.validate!
      payload
    end
  end
end
