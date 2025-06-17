# frozen_string_literal: true

module QrForge
  module Components
    module EyeInner
      #
      # Square component for the inner eye of a finder pattern
      # This draws a 3x3 square in the center of the finder pattern.
      class Square < ForgeComponent
        # @see ForgeComponent#draw
        def draw(y:, x:, quiet_zone:, area:, color: "black", **_)
          position_offset = 2
          area_offset = 4

          x = x + position_offset + quiet_zone
          y = y + position_offset + quiet_zone
          area_with_offset = area - area_offset

          @xml_builder.rect(
            x:,
            y:,
            width: area_with_offset,
            height: area_with_offset,
            fill: color,
            test_id: @test_id
          )
        end
      end
    end
  end
end
