module QrForge
  module Designs
    module Module
      # Square component for the individual module.
      class Square < ForgeDesign

        # @see ForgeComponent#draw
        def draw(y:, x:, quiet_zone:, color: 'black', **_)
          x = x + quiet_zone
          y = y + quiet_zone
          area = 1

          @xml_builder.rect(
            x:,
            y:,
            width: area,
            height: area,
            fill: color
          )
        end
      end
    end
  end
end