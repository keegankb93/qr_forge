# frozen_string_literal: true

RSpec.describe QrForge, type: :feature do
  it "renders a module" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: { qr: { version: 10 } }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css('[test_id^="module_"]')
    end
  end

  it "renders 3 outer_eye patterns" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: { qr: { version: 10 } }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css('[test_id^="finder_pattern_outer_eye_"]', count: 3)
    end
  end

  it "renders 3 inner_eye patterns" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: { qr: { version: 10 } }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css('[test_id^="finder_pattern_inner_eye_"]', count: 3)
    end
  end

  it "renders 6 alignment outer_eye patterns" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: { qr: { version: 10 } }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css('[test_id^="alignment_pattern_outer_eye_"]', count: 6)
    end
  end

  it "renders 6 alignment inner_eye patterns" do
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: { qr: { version: 10 } }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css('[test_id^="alignment_pattern_inner_eye_"]', count: 6)
    end
  end

  it "renders 1 image if provided" do
    image = Base64.strict_encode64("https://example.com/image.png")
    svg = QrForge::Forge.build(
      data: "https://example.com",
      config: {
        qr: { version: 10 },
        design: { image: }
      }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css("image[href='data:image/png;base64,#{image}']", count: 1)
    end
  end

  it "sets the image size relative to the QR code size" do
    image = Base64.strict_encode64("https://example.com/image.png")
    text = "https://example.com"
    qr_data = QrForge::QrData.new(text:)
    layout = QrForge::Layout.new(qr_data:, has_image: true)

    svg = QrForge::Forge.build(
      data: text,
      config: {
        qr: { version: 10 },
        design: {
          image:,
          size: 200
        }
      }
    )

    Capybara.string(svg).tap do |page|
      expect(page).to have_css("image[href='data:image/png;base64,#{image}'][width='#{layout.image_area.size}']")
    end
  end

  it "removes the modules out of the image area" do
    image = Base64.strict_encode64("https://example.com/image.png")
    text = "https://example.com"
    qr_data = QrForge::QrData.new(text:)
    layout = QrForge::Layout.new(qr_data:, has_image: true)

    svg = QrForge::Forge.build(
      data: text,
      config: {
        qr: { version: 10 },
        design: {
          image:,
          size: 200
        }
      }
    )

    image_area = layout.image_area.to_a

    Capybara.string(svg).tap do |page|
      image_area.product(image_area).each do |row, col|
        expect(page).not_to have_css(%([test_id="module_#{row}_#{col}"]))
      end
    end
  end
end
