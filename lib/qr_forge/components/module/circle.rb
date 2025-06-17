# frozen_string_literal: true

module QrForge
  module Components
    module Module
      # Circle component for the individual module.
      class Circle < ForgeComponent
        # @see ForgeComponent#draw
        def draw(y:, x:, quiet_zone:, color: "black", **_)
          r = 0.5
          cx = x + r + quiet_zone
          cy = y + r + quiet_zone

          @xml_builder.circle(
            cx:,
            cy:,
            r:,
            fill: color,
            test_id: @test_id
          )
        end
      end
    end
  end
end
