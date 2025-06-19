# frozen_string_literal: true

RSpec.describe QrForge do
  context "when building payloads" do
    it "raises an error for nil data" do
      expect do
        ::QrForge::Payload.build(data: nil, type: :plain)
      end.to raise_error(ArgumentError, "Invalid data type: NilClass. Expected Hash or String.")
    end

    it "raises an error for invalid data type" do
      expect do
        ::QrForge::Payload.build(data: 12_345, type: :plain)
      end.to raise_error(ArgumentError, "Invalid data type: Integer. Expected Hash or String.")
    end

    it "does not raise an error when string" do
      expect do
        ::QrForge::Payload.build(data: "Valid Data", type: :plain)
      end.not_to raise_error
    end

    it "does not raise an error when hash" do
      expect do
        ::QrForge::Payload.build(data: { latitude: 74, longitude: 85 }, type: :geo)
      end.not_to raise_error
    end
  end

  context "when plain text" do
    it "validates and returns a valid payload" do
      payload = ::QrForge::Payload.build(data: "Hello, World!", type: :plain)
      expect(payload.to_s).to eq("Hello, World!")
    end

    it "raises an error for empty string" do
      expect do
        ::QrForge::Payload.build(data: "", type: :plain)
      end.to raise_error(QrForge::Payloads::PayloadValidationError, "String cannot be empty")
    end
  end

  context "when phone number" do
    it "validates and returns a valid payload" do
      payload = ::QrForge::Payload.build(data: "+1234567890", type: :phone)
      expect(payload.to_s).to eq("tel:+1234567890")
    end

    it "raises an error for invalid phone number format" do
      expect do
        ::QrForge::Payload.build(data: "12345", type: :phone)
      end.to raise_error(QrForge::Payloads::PayloadValidationError, "Invalid phone number format")
    end

    it "does not raise an error for valid phone number" do
      expect do
        ::QrForge::Payload.build(data: "+1234567890", type: :phone)
        ::QrForge::Payload.build(data: "1234567890", type: :phone)
        ::QrForge::Payload.build(data: "123-456-7890", type: :phone)
        ::QrForge::Payload.build(data: "(123) 456-7890", type: :phone)
        ::QrForge::Payload.build(data: "123.456.7890", type: :phone)
      end.not_to raise_error
    end
  end

  context "when geo" do
    it "validates and returns a valid payload" do
      payload = ::QrForge::Payload.build(data: { latitude: 40.712776, longitude: -74.005974 }, type: :geo)
      expect(payload.to_s).to eq("geo:40.712776,-74.005974")
    end

    it "raises an error for invalid latitude" do
      expect do
        ::QrForge::Payload.build(data: { latitude: 100, longitude: -74.005974 }, type: :geo)
      end.to raise_error(QrForge::Payloads::PayloadValidationError, "Latitude or longitude out of range")
    end

    it "raises an error for invalid longitude" do
      expect do
        ::QrForge::Payload.build(data: { latitude: 40.712776, longitude: 200 }, type: :geo)
      end.to raise_error(QrForge::Payloads::PayloadValidationError, "Latitude or longitude out of range")
    end

    it "does not raise an error for valid latitude and longitude" do
      expect do
        ::QrForge::Payload.build(data: { latitude: 40.712776, longitude: -74.005974 }, type: :geo)
      end.not_to raise_error
    end
  end

  context "when url" do
    it "validates and returns a valid payload" do
      payload = ::QrForge::Payload.build(data: "https://example.com", type: :url)
      expect(payload.to_s).to eq("https://example.com")
    end

    it "raises an error for invalid URL format" do
      expect do
        ::QrForge::Payload.build(data: "invalid-url", type: :url)
      end.to raise_error(QrForge::Payloads::PayloadValidationError, "Must be a valid HTTP/HTTPS URL")
    end

    it "does not raise an error for valid URL" do
      expect do
        ::QrForge::Payload.build(data: "http://example.com", type: :url)
        ::QrForge::Payload.build(data: "https://example.com", type: :url)
      end.not_to raise_error
    end
  end

  context "when wifi" do
    it "does not raise an error for valid Wi-Fi payload" do
      expect do
        ::QrForge::Payload.build(data: { ssid: "MyNetwork", password: "MyPassword", encryption: "WPA2" }, type: :wifi)
        ::QrForge::Payload.build(data: { ssid: "MyNetwork", encryption: "nopass" }, type: :wifi)
      end.not_to raise_error
    end

    it "validates and returns a valid payload" do
      payload = ::QrForge::Payload.build(data: { ssid: "MyNetwork", password: "MyPassword", encryption: "WPA" },
                                         type: :wifi)
      expect(payload.to_s).to eq("WIFI:S:MyNetwork;T:WPA;P:MyPassword;;")
    end

    it "raises an error for missing SSID" do
      # This is handled in initialize now as a required keyword argument
      expect do
        ::QrForge::Payload.build(data: { encryption: "WPA", password: "MyPassword" }, type: :wifi)
      end.to raise_error(ArgumentError, "missing keyword: :ssid")
    end

    it "raises an error for invalid encryption type" do
      expect do
        ::QrForge::Payload.build(data: { ssid: "MyNetwork", password: "MyPassword", encryption: "Invalid" },
                                 type: :wifi)
      end.to raise_error(QrForge::Payloads::PayloadValidationError, "Invalid encryption: INVALID")
    end

    it "raises an error for missing password when encryption requires it" do
      expect do
        ::QrForge::Payload.build(data: { ssid: "MyNetwork", encryption: "WPA" }, type: :wifi)
      end.to raise_error(QrForge::Payloads::PayloadValidationError, "Password is required for WPA networks")
    end
  end
end
