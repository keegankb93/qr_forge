# frozen_string_literal: true

module QrForge
  # Responsible only for computing all the exclusion & pattern zones
  class Layout
    FINDER_PATTERN_SIZE = 7
    ALIGNMENT_PATTERN_SIZE = 5

    def initialize(qr_data:, has_image: false)
      @qr_data = qr_data
      @module_count = qr_data.module_count
      @version = qr_data.version
      @modules = qr_data.modules
      @has_image = has_image

      # build_cache
    end

    #
    # Checks if a given row and column are inside the image area.
    # @param row [Integer] the row index
    # @param col [Integer] the column index
    # @return [Boolean] true if the row and column are inside the image area, false otherwise
    def inside_image?(row, col)
      inside_area?(row, col, image_area)
    end

    #
    # Checks if a given row and column are inside the finder patterns.
    # @param row [Integer] the row index
    # @param col [Integer] the column index
    # @return [Boolean] true if the row and column are inside any finder pattern, false otherwise
    def inside_finder?(row, col)
      inside_area?(row, col, finder_patterns[:areas])
    end

    #
    # Checks if a given row and column are inside the alignment patterns.
    # @param row [Integer] the row index
    # @param col [Integer] the column index
    # @return [Boolean] true if the row and column are inside any alignment pattern, false otherwise
    def inside_alignment?(row, col)
      inside_area?(row, col, alignment_patterns[:areas])
    end

    #
    # Returns the image area as a Range of rows and columns.
    # The image area is centered in the QR code and its size is based on the module count.
    # @return [Range] the range of rows and columns that the image area covers
    def image_area
      @image_area ||= begin
        raw  = (@module_count * 0.30).round
        size = raw.even? ? raw + 1 : raw
        start_idx = ((@module_count - size) / 2.0).floor
        (start_idx...(start_idx + size))
      end
    end

    #
    # Returns the finder patterns' coordinates and areas.
    # Coordinates are the top-left corners of the finder patterns.
    # Areas are the ranges of rows and columns that the finder patterns cover.
    # @return [Hash] with keys :coordinates and :areas
    def finder_patterns
      @finder_patterns ||= begin
        offset = @module_count - FINDER_PATTERN_SIZE
        coordinates = [[0, 0], [0, offset], [offset, 0]]
        areas = []

        coordinates.map do |row, col|
          areas << [(row...(row + FINDER_PATTERN_SIZE)), (col...(col + FINDER_PATTERN_SIZE))]
        end

        { coordinates: coordinates, areas: areas }
      end
    end

    # TODO: Remove some complexity out of this method
    # Returns the alignment patterns' coordinates and areas.
    # Coordinates are the top-left corners of the alignment patterns.
    # Areas are the ranges of rows and columns that the alignment patterns cover.
    # @return [Hash] with keys :coordinates and :areas
    def alignment_patterns
      @alignment_patterns ||= begin
        # Offset from center to top-left corner of the alignment pattern
        half_offset = (ALIGNMENT_PATTERN_SIZE - 1) / 2

        # RQRCodeCore provides a helper method to get the alignment pattern centers
        alignment_center_coordinates = RQRCodeCore::QRUtil.get_pattern_positions(@version)

        # Filter out centers that are inside finder patterns or the image area
        valid_alignment_coordinates = alignment_center_coordinates.product(alignment_center_coordinates).reject do |center_row, center_col|
          inside_finder?(center_row, center_col) || (@has_image && inside_image?(center_row, center_col))
        end

        locations = { coordinates: [], areas: [] }

        # Map valid alignment centers to their top-left corners and areas
        valid_alignment_coordinates.map do |center_row, center_col|
          top_left_row = center_row - half_offset
          top_left_col = center_col - half_offset

          locations[:coordinates] << [top_left_row, top_left_col]

          row_range = top_left_row...(top_left_row + ALIGNMENT_PATTERN_SIZE)
          col_range = top_left_col...(top_left_col + ALIGNMENT_PATTERN_SIZE)

          locations[:areas] << [row_range, col_range]
        end

        locations
      end
    end

    private

    #
    # Checks if a given row and column are inside a specified area.
    # @return [Boolean] true if the row and column are inside the area, false otherwise
    def inside_area?(row, col, area)
      case area
      when Range
        area.cover?(row) && area.cover?(col)
      when Array
        Array(area).any? do |row_range, col_range|
          row_range.cover?(row) && col_range.cover?(col)
        end
      else
        raise ArgumentError, "Invalid area type: #{area.class}. Expected Range or Array of Ranges."
      end
    end

    # Potentially implement caching for layouts. Benchmark saves 100-150ms on a version 40 QR code
    # Most time spent is via RQRCodeCore.new and vips
    # def build_cache
    #   @cache = {
    #   }
    #
    #   @cache[:logo] ||= compute_logo_coords
    #   @cache[:finder] ||= compute_coords_for_areas(finder_patterns[:areas])
    #   @cache[:alignment] ||= compute_coords_for_areas(alignment_patterns[:areas])
    #
    #   @cache
    # end

    # Turn a single Range (logo area) into a Set of [row,col] pairs
    # def compute_logo_coords
    #   coords = []
    #
    #   # Declare for readability
    #   row_range = logo_area
    #   col_range = logo_area
    #
    #   row_range.to_a.each do |r|
    #     col_range.to_a.each do |c|
    #       coords << [r, c]
    #     end
    #   end
    #   coords.to_set
    # end
    #
    # # Turn an Array of [row_range, col_range] into a Set of all covered coords
    # def compute_coords_for_areas(areas)
    #   coords = []
    #   areas.each do |row_range, col_range|
    #     row_range.to_a.each do |r|
    #       col_range.to_a.each do |c|
    #         coords << [r, c]
    #       end
    #     end
    #   end
    #   coords.to_set
    # end
  end
end
