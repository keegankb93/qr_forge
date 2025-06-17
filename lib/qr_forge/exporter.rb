# frozen_string_literal: true

require "vips"

module QrForge
  #
  # Handles exporting the generated QR code in various formats.
  class Exporter
    def initialize(size:, canvas_size:, export_options: {})
      @size = size
      @canvas_size = canvas_size
      @format = export_options[:format] || :svg
    end

    def export(svg)
      case @format
      when :svg
        svg
      when :png
        export_png(svg)
      else
        raise "Unsupported export format: #{@format}"
      end
    end

    private

    def export_png(svg)
      image = Vips::Image.svgload_buffer(svg, dpi: calculate_dpi)
      buffer = image.write_to_buffer(".png", compression: 9)
      StringIO.new(buffer)
    end

    def calculate_dpi
      pixels_per_module = @canvas_size.floor
      # TODO: Allow ppm to be set by user or set by media_type i.e. print, screen etc.
      pixels_per_module * 8
    end
  end
end
