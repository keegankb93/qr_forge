module QrForge
  module Designs
    class ForgeDesign

      #
      # @param xml_builder [Nokogiri::XML::Builder]
      def initialize(xml_builder:)
        @xml_builder = xml_builder
      end

      # TODO: For modules pass the next and prev module to change design based on if there is another module next or behind
      #
      # @param y [Integer] The row index
      # @param x [Integer] The col index
      # @param quiet_zone [Integer] The padding around the QR code
      # @param area [Integer] width and height of the area to draw (width and height are equal)
      def draw(y:, x:, quiet_zone:, area:, **_)
        raise NotImplementedError, "FinderBorder::Base subclasses must implement `draw`"
      end
    end
  end
end