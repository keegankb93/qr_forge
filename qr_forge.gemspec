# frozen_string_literal: true

require_relative "lib/qr_forge/version"

Gem::Specification.new do |spec|
  spec.name = "qr_forge"
  spec.version = QrForge::VERSION
  spec.authors = ["Keegankb93"]
  spec.email = ["keegankb@gmail.com"]

  spec.summary = "QRForge is a Ruby gem for rendering QR codes with different designs and formats."
  spec.homepage = "https://github.com/keegankb93/qr_forge"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/keegankb93/qr_forge"
  spec.metadata["changelog_uri"] = "https://github.com/keegankb93/qr_forge/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "base64", "~> 0.3.0"
  spec.add_dependency "nokogiri", "~> 1.18"
  spec.add_dependency "rqrcode_core", "~> 2.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.add_development_dependency "capybara", "~> 3.40"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
