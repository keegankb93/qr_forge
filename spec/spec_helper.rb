# frozen_string_literal: true

require "qr_forge"
# QrForge.loader.eager_load(force: true)
require "rspec"
require "capybara"
require "base64"

ENV["SVG_OUTPUT_MODE"] = "test"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
