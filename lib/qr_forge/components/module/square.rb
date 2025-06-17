# frozen_string_literal: true

module QrForge
  module Components
    module Module
      # Square component for the individual module.
      class Square < ForgeComponent
        # @see ForgeComponent#draw
        def draw(y:, x:, quiet_zone:, color: "black", **_)
          x += quiet_zone
          y += quiet_zone
          area = 1

          @xml_builder.rect(
            x:,
            y:,
            width: area,
            height: area,
            fill: color,
            test_id: @test_id
          )
        end
      end
    end
  end
end
