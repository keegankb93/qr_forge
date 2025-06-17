# frozen_string_literal: true

RSpec.describe QrForge, type: :feature do
  context "when outer_eye" do
    it "renders as a square" do
      svg = QrForge::Forge.build(
        text: "https://example.com",
        config: {
          qr: { version: 10 },
          components: {
            outer_eye: ::QrForge::Components::EyeOuter::Square
          }
        }
      )

      Capybara.string(svg).tap do |page|
        expect(page).to have_css('rect[test_id="finder_pattern_outer_eye_0"]')
      end
    end

    it "renders as a circle" do
      svg = QrForge::Forge.build(
        text: "https://example.com",
        config: {
          qr: { version: 10 },
          components: {
            outer_eye: ::QrForge::Components::EyeOuter::Circle
          }
        }
      )

      Capybara.string(svg).tap do |page|
        expect(page).to have_css('circle[test_id="finder_pattern_outer_eye_0"]')
      end
    end
  end

  context "when inner_eye" do
    it "renders as a square" do
      svg = QrForge::Forge.build(
        text: "https://example.com",
        config: {
          qr: { version: 10 },
          components: {
            inner_eye: ::QrForge::Components::EyeInner::Square
          }
        }
      )

      Capybara.string(svg).tap do |page|
        expect(page).to have_css('rect[test_id="finder_pattern_inner_eye_0"]')
      end
    end

    it "renders as a circle" do
      svg = QrForge::Forge.build(
        text: "https://example.com",
        config: {
          qr: { version: 10 },
          components: {
            inner_eye: ::QrForge::Components::EyeInner::Circle
          }
        }
      )

      Capybara.string(svg).tap do |page|
        expect(page).to have_css('circle[test_id="finder_pattern_inner_eye_0"]')
      end
    end
  end

  context "when module" do
    it "renders as a square" do
      svg = QrForge::Forge.build(
        text: "https://example.com",
        config: {
          qr: { version: 10 },
          components: {
            module: ::QrForge::Components::Module::Square
          }
        }
      )

      Capybara.string(svg).tap do |page|
        expect(page).to have_css('rect[test_id^="module_"]')
      end
    end

    it "renders as a circle" do
      svg = QrForge::Forge.build(
        text: "https://example.com",
        config: {
          qr: { version: 10 },
          components: {
            module: ::QrForge::Components::Module::Circle
          }
        }
      )

      Capybara.string(svg).tap do |page|
        expect(page).to have_css('circle[test_id^="module_"]')
      end
    end
  end
end
