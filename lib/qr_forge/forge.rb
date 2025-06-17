# frozen_string_literal: true

require "vips"
require_relative "renderer"
require_relative "exporter"

module QrForge
  #
  # Entry point for building QRCodes
  class Forge
    DEFAULT_DESIGNS = {
      outer_eye: ::QrForge::Designs::EyeOuter::Circle,
      inner_eye: ::QrForge::Designs::EyeInner::Circle,
      module: ::QrForge::Designs::Module::Circle
    }.freeze

    def self.build(text:, size: 6, designs: {}, export_options: {}, design_options: {})
      new(text:, size:, designs:, export_options:, design_options:).build
    end

    def initialize(text:, size:, designs:, export_options:, design_options:)
      @data = QrForge::QrData.new(text:, size:)
      @renderer = QrForge::Renderer.new(qr_data: @data, designs: DEFAULT_DESIGNS.merge(designs), design_options:)
      @exporter = QrForge::Exporter.new(size:, canvas_size: @renderer.canvas_size, export_options:)
    end

    def build
      svg = @renderer.to_svg
      @exporter.export(svg)
    end
  end
end
