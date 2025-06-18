# frozen_string_literal: true

require "zeitwerk"

# Entry point for the QrForge gem.
module QrForge
  def self.loader
    @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
      loader.tag = "qr_forge"
      loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
      loader.setup
    end
  end

  loader
end
