# frozen_string_literal: true

module QrForge
  #
  # Entry point for building QRCodes
  class Forge
    def initialize(data:, type:, config:)
      version = config.dig(:qr, :version)

      @data = QrForge::QrData.new(text: QrForge::Payload.build(data:, type:).to_s, version:)
      @renderer = QrForge::Renderer.new(qr_data: @data, config:)
      @exporter = QrForge::Exporter.new(config:)
    end

    #
    # Builds a QR code with the given parameters.
    # @param data [String, Hash] The data to encode in the QR code. This can be a string or a hash for specific payloads.
    # @param type [Symbol] The type of QR code to build (e.g., :plain, :url)
    # @param config [Hash] Configuration options for the QR code, including design and export settings.
    #   - `:qr` - QR code specific settings (e.g., version).
    #   - `:design` - Design specific settings (e.g., colors, shapes).
    #   - `:output` - Export specific settings (e.g., format).
    # @return [String, StringIO] The SVG or PNG representation of the QR code
    def self.build(data:, type: :url, config: {})
      new(data:, type:, config:).build
    end

    def build
      svg = @renderer.to_svg
      @exporter.export(svg)
    end
  end
end
