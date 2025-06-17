# frozen_string_literal: true
require "nokogiri"
require_relative "layout"

module QrForge
  class Renderer
    # Rendering of how row and column indices relate to the finder pattern:
    #
    #               col_index (x)
    #              0 1 2 3 4 5 6
    # row_index (y)
    #   0          # # # # # # #
    #   1          # . . . . . #
    #   2          # . # # # . #
    #   3          # . # X # . #   ← (3,3) is inside the finder
    #   4          # . # # # . #
    #   5          # . . . . . #
    #   6          # # # # # # #
    #
    # Legend:
    #   "#" = dark module (true)
    #   "." = light module (false)
    #   "X" = example point at (row_index=3, col_index=3)
    #

    def initialize(qr_data:, designs:, design_options:)
      @qr_data = qr_data
      @designs = designs
      @quiet_zone = 4
      @module_count = qr_data.module_count
      @logo = design_options[:logo]
      # TODO: Color should be a hash with keys for each color for each design element.
      @color = design_options[:color] || "black"
      @layout = QrForge::Layout.new(qr_data:, logo: @logo.present?)
    end

    #
    # Generates the SVG representation of the QR code.
    def to_svg
      Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.svg(
          width: canvas_size,
          height: canvas_size,
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: "0 0 #{canvas_size} #{canvas_size}"
        ) do
          draw_background(xml)
          draw_logo(xml)
          draw_finder_patterns(xml)
          draw_alignment_patterns(xml)
          draw_modules(xml)
        end
      end.to_xml
    end

    #
    # Calculates the size of the canvas for the QR code.
    # The canvas size is the module count plus the quiet zone on both sides.
    #
    # @return [Integer] the total size of the canvas in modules
    #
    # The quiet zone is a margin around the QR code to ensure readability.
    def canvas_size
      @canvas_size ||= @module_count + (@quiet_zone * 2)
    end

    #
    # Draws the logo in the center of the QR code if a logo is provided and the QR code version is 2 or higher.
    # The logo is drawn in the area defined by the logo_range, which is a Range of row indices.
    def draw_logo(xml)
      return unless @logo.present? && @qr_data.version >= 2

      logo_range = @layout.logo_area # a Range (row indices) for the logo
      size = logo_range.size # width/height in modules

      # Convert module coords → SVG coords (including quiet zone)
      x = logo_range.first + @quiet_zone
      y = logo_range.first + @quiet_zone

      xml.image(
        href: "data:image/png;base64,#{@logo}",
        x:,
        y:,
        width: size,
        height: size,
        preserveAspectRatio: "none"
      )
    end

    #
    # Draws the background rectangle for the QR code. Should always be white to ensure contrast.
    # The rectangle is drawn with a size that includes the quiet zone around the QR code.
    def draw_background(xml)
      xml.rect(
        x: -@quiet_zone,
        y: -@quiet_zone,
        width: canvas_size + @quiet_zone,
        height: canvas_size + @quiet_zone,
        fill: "white"
      )
    end

    #
    # Draws the finder patterns in the QR code.
    # The finder patterns are the large squares in the corners of the QR code.
    def draw_finder_patterns(xml)
      @layout.finder_patterns[:coordinates].each do |r, c|
        %i[outer_eye inner_eye].each do |layer|
          @designs[layer]
            .new(xml_builder: xml)
            .draw(y: r, x: c, quiet_zone: @quiet_zone, area: QrForge::Layout::FINDER_PATTERN_SIZE, color: @color)
        end
      end
    end

    #
    # Draws the alignment patterns in the QR code.
    # The alignment patterns are smaller squares that help with error correction.
    def draw_alignment_patterns(xml)
      size = QrForge::Layout::ALIGNMENT_PATTERN_SIZE

      @layout.alignment_patterns[:coordinates].each do |r, c|
        %i[outer_eye inner_eye].each do |layer|
          @designs[layer]
            .new(xml_builder: xml)
            .draw(y: r, x: c, quiet_zone: @quiet_zone, area: size, color: @color)
        end
      end
    end

    # TODO: This can probably be optional as we can also just layer the logo on top of the QR code.
    # Removes modules in the logo area if a logo is present and the QR code version is 2 or higher.
    #
    # @return [void]
    def remove_modules_for_logo
      return unless @logo.present? && @qr_data.version >= 2

      logo_area = @layout.logo_area

      logo_area.each do |r|
        logo_area.each do |c|
          @qr_data.modules[r][c] = false
        end
      end
    end

    #
    # Draws the individual modules of the QR code.
    def draw_modules(xml)
      remove_modules_for_logo

      @qr_data.modules.each_with_index do |row, r|
        row.each_with_index do |cell, c|
          next if !cell ||
                  @layout.inside_finder?(r, c) ||
                  @layout.inside_alignment?(r, c)

          @designs[:module]
            .new(xml_builder: xml)
            .draw(y: r, x: c, quiet_zone: @quiet_zone, area: 1, color: @color)
        end
      end
    end
  end
end
