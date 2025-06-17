# frozen_string_literal: true

require "vips"

module QrForge
  #
  # Handles exporting the generated QR code in various formats.
  class Exporter
    def initialize(config:)
      @format = config.dig(:output, :format) || :svg
    end

    def export(svg)
      case @format
      when :svg
        svg
      when :png
        as_png(svg)
      else
        raise "Unsupported export format: #{@format}"
      end
    end

    private

    #
    # Exports the SVG to PNG format using Vips.
    # @param svg [String] The SVG content to convert
    # @return [StringIO] A StringIO object containing the PNG data
    def as_png(svg)
      image = Vips::Image.svgload_buffer(svg)
      # TODO: Compression doesn't really seem to give much noticeable difference in quality or file size.
      buffer = image.write_to_buffer(".png")

      StringIO.new(buffer)
    end
  end
end
