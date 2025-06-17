# !! Docs are still being written !! #

# QR Forge

This library is a QR Code renderer that lets you customize almost every aspect of a QR Code. From module design to a logo, this library is meant to be design-extensible, which means you can render your own components such as modules, the outer eyes and inner eyes etc. in your own custom SVG shapes.

# Installation

```gem install qr_forge```

or if using bundler

```bundle add qr_forge```

Note: To export in the PNG format you will also want to install vips on your machine

```brew install vips```

# Usage

To create a QR Code you can simply do the following:

```ruby
QrForge::Forge.build(text: "https://yourlinkhere.com")
```

If you want an (SVG) QRCode fast, that's all there is to it. Everything else is covered by default values, however, you can tweak anything you want, which we will go through in the next section.

## Configuration

The library tries to provide sensible defaults, but defaults can be subjective, so the following shows a configuration object that you can pass to the QR Code.

```ruby
QrForge::Forge.build(
  text: "https://www.google.com",
  config: {
    qr: { version: 10 },
    components: { inner_eye: QrForge::Components::EyeInner::Square },
    design: {
      size: 800,
      colors: { module: 'blue', outer_eye: 'cyan', inner_eye: 'skyblue' },
      image: Base64.strict_encode64(...)
    },
    output: { format: :png }
  }
)
```

##### QR

This hash provides details to the underlying QR code generator (see: https://github.com/whomwah/rqrcode_core).

_version_ dictates the module count or size of the QR Code and how much data it can hold. It does not necessarily dictate the dimensions, however, it will be unreadable if you choose too small of a size, but a larger QR code version. (see: https://www.qrcode.com/en/about/version.html)

##### Components

This hash can have up to 3 components:
- outer_eye
<img width="77" alt="Screenshot 2025-06-17 at 1 23 39 AM" src="https://github.com/user-attachments/assets/ccef3f08-cc4b-43c7-95b4-8d6c707f5f5a" />

- inner_eye
<img width="77" alt="Screenshot 2025-06-17 at 1 24 22 AM" src="https://github.com/user-attachments/assets/c21bb175-00c2-4179-a20a-4e505ad37df1" />

- module
<img width="216" alt="Screenshot 2025-06-17 at 1 25 24 AM" src="https://github.com/user-attachments/assets/f670d5fd-e2dc-42cc-9bff-d77a51d65fa1" />

This is what the circle outer_eye component looks like:

```ruby
# frozen_string_literal: true

module QrForge
  module Components
    module EyeOuter
      class Circle < ForgeComponent
        DEFAULT_STROKE_WIDTH = 1.0

        # @see ForgeComponent#draw
        # Draws a circle that fills the full 'area' box, inset by half the stroke so it
        # never overlaps the modules beneath.
        def draw(y:, x:, quiet_zone:, area:, color: "black", **_)
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
            fill: "transparent",
            test_id: @test_id
          )
        end
      end
    end
  end
end
```

And the square for comparison:

```ruby
# frozen_string_literal: true

module QrForge
  module Components
    module EyeOuter
      class Square < ForgeComponent
        # @see ForgeComponent#draw
        def draw(y:, x:, quiet_zone:, area:, color: "black", **_)
          x += quiet_zone
          y += quiet_zone

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
            x: x + inset,
            y: y + inset,
            width: inner,
            height: inner,
            fill: color,
            test_id: @test_id
          )
        end
      end
    end
  end
end
```

All components must inherit from the base ForgeComponent. You can look at that to see what is available to be used (this is on the roadmap to allow more design variations).

If you create your own designs, follow the same pattern and pass them into the components config. It will merge them with the default components, so if you only want to change one or two of the components, but not all three, you can!

##### Design

```size: 800```

This sets the width and height of the svg. I recommend that you set this to a higher value than you plan to use as the SVG will scale well without needing to use any image processing like vips. If you do want to use your own strategies for image processing, I still recommend a higher size and do with the SVG as you wish.

```colors: { module: 'blue', outer_eye: 'cyan', inner_eye: 'skyblue' }```

This will set the fill or stroke appropriately for the respective component.

``` image: ...```

A base64 encoded image that will be placed in the center of your QR Code. This scales with the version of the QR Code and is strictly set as to make sure that we do not remove more data that can be recovered through the error correcting algorithms.

##### Output

``` output: { format: :png }})```

This will use vips to process the svg and return it as a PNG. If you want to do your own image processing, you can leave this off as the default is the raw SVG string.


## Roadmap
- Color gradients for components
- More data types i.e. wifi, passkey etc.
- Image background and shape improvements
- More default component selections
