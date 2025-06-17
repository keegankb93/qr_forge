module QrForge
  module Designs
    module EyeOuter
      class Square < ForgeDesign

        # @see ForgeDesign#draw
        def draw(y:, x:, quiet_zone:, area:, color: 'black', **_)
          x = x + quiet_zone
          y = y + quiet_zone

          # Draw the outer black square (7x7)
          @xml_builder.rect(
            x:,
            y:,
            width: area,
            height: area,
            fill: color
          )

          # Draw the inner (cutout) square (5x5) to create the finder pattern
          inset = 1
          inner = area - 2

          @xml_builder.rect(
            x:      x + inset,
            y:      y + inset,
            width:  inner,
            height: inner,
            fill:   "white"
          )

          yield if block_given?
        end
      end
    end
  end
end