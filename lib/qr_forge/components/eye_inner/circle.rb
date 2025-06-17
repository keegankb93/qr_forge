# frozen_string_literal: true

module QrForge
  module Components
    module EyeInner
      class Circle < ForgeComponent
        # how many modules to inset on *each* side
        INSET_MODULES = 2

        # @see ForgeComponent#draw
        def draw(y:, x:, quiet_zone:, area:, color: "black", **_)
          # 1) full-finder radius in modules
          full_radius = area / 2.0

          # 2) subtract that many modules from *each* side
          r = full_radius - INSET_MODULES

          return if r <= 0 # no room to draw

          # 3) center calculation
          cx = x + quiet_zone + full_radius
          cy = y + quiet_zone + full_radius

          @xml_builder.circle(
            cx:,
            cy:,
            r: r,
            fill: color,
            test_id: @test_id
          )
        end
      end
    end
  end
end
