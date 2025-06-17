require "rqrcode_core/qrcode"

module QrForge
  #
  # QrData is a wrapper around RQRCodeCore::QRCode that provides
  # a simplified interface for accessing QR code data.
  # We can also add additional data related to the QR code, but not always RQRCodeCore related
  class QrData
    attr_reader :modules, :version, :module_count, :quiet_zone

    def initialize(text:, size:, level: :h)
      qr = RQRCodeCore::QRCode.new(text, size: size, level: level)
      @version = qr.version
      @modules = qr.modules.map(&:dup)
      @module_count = @modules.size
    end
  end
end