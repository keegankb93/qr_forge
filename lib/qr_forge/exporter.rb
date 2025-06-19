# frozen_string_literal: true

module QrForge
  #
  # Handles exporting the generated QR code in various formats.
  class Exporter
    def initialize(config:)
      @format = config.dig(:output, :format) || :svg
    end

    #
    # Exports the generated QR code in the specified format.
    # @param svg [String] The generated SVG content of the QR code
    # @return [String] The exported QR code in the specified format
    # @raise [RuntimeError] if the format is unsupported
    def export(svg)
      case @format
      when :svg
        process_svg(svg)
      else
        raise "Unsupported export format: #{@format}"
      end
    end

    private

    #
    # Performs any last-minute processing on the svg before exporting if applicable
    # @param [String] svg the preprocessed svg
    # @return [String] the final svg
    def process_svg(svg)
      return svg if ENV["SVG_OUTPUT_MODE"] == "test"

      clean(svg)
    end

    #
    # Cleans the SVG by removing test_id attributes.
    # @param svg [String] The generated SVG
    # @return [String] The cleaned SVG content
    def clean(svg)
      doc = Nokogiri::XML(svg)
      doc.xpath("//@test_id").remove
      doc.to_xml
    end
  end
end
