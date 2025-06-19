# frozen_string_literal: true

module QrForge
  #
  # Handles exporting the generated QR code in various formats.
  class Exporter
    def initialize(config:)
      @format = config.dig(:output, :format) || :svg
      @clean_output = config.dig(:output, :clean_output) != false
    end

    def export(svg)
      case @format
      when :svg
        clean_svg(svg)
      else
        raise "Unsupported export format: #{@format}"
      end
    end

    private

    #
    # Cleans the SVG by removing test_id attributes.
    # @param svg [String] The generated SVG
    # @return [String] The cleaned SVG content
    def clean_svg(svg)
      doc = Nokogiri::XML(svg)
      doc.xpath("//@test_id").remove
      doc.to_xml
    end
  end
end
