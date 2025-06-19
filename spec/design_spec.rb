# frozen_string_literal: true

RSpec.describe QrForge, type: :feature do
  it "colors the outer_eye blue" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: {
        qr: { version: 10 },
        design: {
          colors: {
            outer_eye: "blue"
          }
        }
      }
    )

    Capybara.string(svg).tap do |page|
      # Default is circle, so check for stroke color intead of fill
      expect(page).to have_css('[test_id="finder_pattern_outer_eye_0"][stroke="blue"]')
    end
  end

  it "colors the inner_eye blue" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: {
        qr: { version: 10 },
        design: {
          colors: {
            inner_eye: "blue"
          }
        }
      }
    )

    Capybara.string(svg).tap do |page|
      # Default is circle, so check for stroke color intead of fill
      expect(page).to have_css('[test_id="finder_pattern_inner_eye_0"][fill="blue"]')
    end
  end

  it "colors the module blue" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: {
        qr: { version: 10 },
        design: {
          colors: {
            module: "blue"
          }
        }
      }
    )

    Capybara.string(svg).tap do |page|
      # Default is circle, so check for stroke color intead of fill
      expect(page).to have_css('[test_id^="module_"][fill="blue"]')
    end
  end

  it "sets the height and width of the SVG" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: {
        qr: { version: 10 },
        design: {
          size: 200
        }
      }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css('svg[width="200"][height="200"]')
    end
  end
end
