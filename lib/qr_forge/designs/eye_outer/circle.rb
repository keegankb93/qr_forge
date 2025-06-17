module QrForge
  module Designs
    module EyeOuter
      class Circle < ForgeDesign

        DEFAULT_STROKE_WIDTH = 1.0

        # @see ForgeDesign#draw
        # Draws a circle that fills the full 'area' box, inset by half the stroke so it
        # never overlaps the modules beneath.
        def draw(y:, x:, quiet_zone:, area:, color: 'black')
          stroke_width = DEFAULT_STROKE_WIDTH

          # Radius = (full width of box – one stroke) / 2
          r = (area - stroke_width) / 2.0

          # Center of the N×N box (plus quiet_zone offset)
          cx = x + quiet_zone + (area / 2.0)
          cy = y + quiet_zone + (area / 2.0)

          @xml_builder.circle(
            cx: cx,
            cy: cy,
            r: r,
            'stroke-width': stroke_width,
            stroke: color,
            fill: 'transparent'
          )
        end

      end
    end
  end
end
