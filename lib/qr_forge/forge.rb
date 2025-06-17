# frozen_string_literal: true

module QrForge
  #
  # Entry point for building QRCodes
  class Forge

    def initialize(text:, config:)
      version = config.dig(:qr, :version)

      @data = QrForge::QrData.new(text:, version:)
      @renderer = QrForge::Renderer.new(qr_data: @data, config:)
      @exporter = QrForge::Exporter.new(config:)
    end

    #
    # Builds a QR code with the given parameters.
    # @param text [String] The text/data to encode in the QR code
    # @param size [Integer] The size of the QR code in modules [1-40]
    # @return [String, StringIO] The SVG or PNG representation of the QR code
    def self.build(text:, config: {})
      new(text:, config:).build
    end

    def build
      svg = @renderer.to_svg
      @exporter.export(svg)
    end
  end
end
