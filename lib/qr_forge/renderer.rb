# frozen_string_literal: true

require "nokogiri"
require_relative "layout"

module QrForge
  #
  # Renderer class is responsible for generating the SVG representation of a QR code.
  #
  # It takes QR data, design options, and renders the QR code with finder patterns, alignment patterns,
  # and modules. It also handles the image if provided.
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

    DEFAULT_COLORS = {
      module: "black",
      outer_eye: "black",
      inner_eye: "black"
    }.freeze

    DEFAULT_COMPONENTS = {
      outer_eye: ::QrForge::Components::EyeOuter::Circle,
      inner_eye: ::QrForge::Components::EyeInner::Circle,
      module: ::QrForge::Components::Module::Circle
    }.freeze

    def initialize(qr_data:, config:)
      @qr_data = qr_data
      @components = DEFAULT_COMPONENTS.merge(config.fetch(:components, {}))
      @quiet_zone = 4
      @module_count = qr_data.module_count
      @image = config.dig(:design, :image)
      @width = config.dig(:output, :width)
      @height = config.dig(:output, :width)
      @colors = DEFAULT_COLORS.merge(config.dig(:design, :colors) || {})
      @layout = QrForge::Layout.new(qr_data:, has_image: image_present?)
    end

    #
    # Generates the SVG representation of the QR code.
    def to_svg
      Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.svg(
          width: @width || canvas_size,
          height: @height || canvas_size,
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: "0 0 #{canvas_size} #{canvas_size}"
        ) do
          draw_background(xml)
          draw_image(xml)
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

    private

    #
    # Checks if an image is present.
    # @return [Boolean] true if an image is provided, false otherwise
    def image_present?
      !@image.nil? && !@image.empty?
    end

    #
    # Draws the image in the center of the QR code if an image is provided and the QR code version is 2 or higher.
    # The image is drawn in the area defined by the image_range, which is a Range of row indices.
    def draw_image(xml)
      return unless image_present? && @qr_data.version >= 2

      image_range = @layout.image_area # a Range (row indices) for the image
      size = image_range.size # width/height in modules

      # Convert module coords → SVG coords (including quiet zone)
      x = image_range.first + @quiet_zone
      y = image_range.first + @quiet_zone

      xml.image(
        test_id: "image",
        href: "data:image/png;base64,#{@image}",
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
        test_id: "background",
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
      @layout.finder_patterns[:coordinates].each.with_index do |(r, c), idx|
        %i[outer_eye inner_eye].each do |layer|
          @components[layer]
            .new(xml_builder: xml, test_id: "finder_pattern_#{idx}")
            .draw(y: r, x: c, quiet_zone: @quiet_zone, area: QrForge::Layout::FINDER_PATTERN_SIZE, color: @colors[layer])
        end
      end
    end

    #
    # Draws the alignment patterns in the QR code.
    # The alignment patterns are smaller squares that help with error correction.
    def draw_alignment_patterns(xml)
      size = QrForge::Layout::ALIGNMENT_PATTERN_SIZE

      @layout.alignment_patterns[:coordinates].each.with_index do |(r, c), idx|
        %i[outer_eye inner_eye].each do |layer|
          @components[layer]
            .new(xml_builder: xml, test_id: "alignment_pattern_#{idx}")
            .draw(y: r, x: c, quiet_zone: @quiet_zone, area: size, color: @colors[layer])
        end
      end
    end

    # TODO: This can probably be optional as we can also just layer the image on top of the QR code.
    # Removes modules in the image area if a image is present and the QR code version is 2 or higher.
    #
    # @return [void]
    def remove_modules_for_image
      return unless image_present? && @qr_data.version >= 2

      image_area = @layout.image_area

      image_area.each do |r|
        image_area.each do |c|
          @qr_data.modules[r][c] = false
        end
      end
    end

    #
    # Draws the individual modules of the QR code.
    def draw_modules(xml)
      remove_modules_for_image

      @qr_data.modules.each_with_index do |row, r|
        row.each_with_index do |cell, c|
          next if !cell ||
                  @layout.inside_finder?(r, c) ||
                  @layout.inside_alignment?(r, c)

          @components[:module]
            .new(xml_builder: xml, test_id: "module_#{r}_#{c}")
            .draw(y: r, x: c, quiet_zone: @quiet_zone, area: 1, color: @colors[:module])
        end
      end
    end
  end
end
