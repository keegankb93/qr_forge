![output](https://github.com/user-attachments/assets/6d360bbb-511d-43f4-a356-8adf634efac0)

An example of the output of QR Forge

# QR Forge

This library is a QR Code renderer that lets you customize almost every aspect of a QR Code. From module design to a logo, this library is meant to be design-extensible, which means you can render your own components such as modules, the outer eyes and inner eyes etc. in your own custom SVG shapes.

# Installation

```shell 
gem install qr_forge
```

or if using bundler

```shell
bundle add qr_forge
```

# Usage

To create a QR Code you can simply do the following:

### Payloads

Did you know that QR Codes can store different pieces of data such as wifi access, passkeys, geolocation and quite a few more! Below are a few different types of data payloads that are implemented with in the gem. More will be added as needed.

#### Plain text

```ruby
QrForge::Forge.build(data: "https://yourlinkhere.com", type: :plain)
```

#### URL

```ruby
QrForge::Forge.build(data: "https://yourlinkhere.com", type: :url)
```

#### Wifi

```ruby
QrForge::Payload.build(data: { ssid: "MyNetwork", password: "MyPassword", encryption: "WPA" }, type: :wifi)
```
Fields: 
- ssid,
- password
- encryption (WEP WPA WPA2 WPA3)
- hidden (true/false)

>[!NOTE]
>You can also pass "nopass" to encryption which means a password does not need to be provided either (public wifi etc.)

#### Geo/Coordinates

```ruby
QrForge::Payload.build(data: { latitude: 40.712776, longitude: -74.005974 }, type: :geo)
```
Fields:
- latitude
- longitude

#### Phone number

```ruby
QrForge::Payload.build(data: "+1234567890", type: :phone)
QrForge::Payload.build(data: "1234567890", type: :phone)
QrForge::Payload.build(data: "123-456-7890", type: :phone)
QrForge::Payload.build(data: "(123) 456-7890", type: :phone)
QrForge::Payload.build(data: "123.456.7890", type: :phone)
```

More are planned to be added.

### Design

Design controls the look and feel of the QR Code from the [QR Version](https://www.qrcode.com/en/about/version.html) to the colors of the individual modules.

##### QR

```ruby
QrForge::Payload.build(..., design: { qr { version: 10 } }, ...)
```
Fields:
- Version
  
##### Image

```ruby
QrForge::Payload.build(..., design: { image: "..." }, ...)
```
The image should be a **Base64 encoded** image like the following:

```ruby
Base64.strict_encode64(image_png_binary)
```
More image formats will be added as needed or required.

##### Colors

```ruby
QrForge::Payload.build(..., design: {colors: { outer_eye: "#30363D", inner_eye: "#30363D", module: "#484F58" }, ...)
```
Fields:
- outer_eye
- inner_eye
- module
  
Any hex code or plain color such as "red", "cyan", "peru", etc. will work as the color value.

See the Components section for more details on which field references what component of the QR Code.

### Output

```ruby
QrForge::Payload.build(..., output: { size: 250 }, ...)
```
Fields:
- size
  
QR Codes are equal in height and width, the size will control the width and height of the returned SVG.

There is only an ouput of SVG format, see this PR for reasoning: https://github.com/keegankb93/qr_forge/pull/1

If different formats are a requirement and that requirement means the image conversion should take place in the gem, send me a message with your usecase. SVG as the format should be good for almost all usecases.

### Components

```ruby
QrForge::Payload.build(..., components: {
                              outer_eye: QrForge::Components::EyeOuter::Square,
                              inner_eye: QrForge::Components::EyeInner::Square,
                              module: QrForge::Components::Module::Squre
                            },
                        ...)
```
Fields:
- outer_eye
<img width="77" alt="Screenshot 2025-06-17 at 1 23 39 AM" src="https://github.com/user-attachments/assets/ccef3f08-cc4b-43c7-95b4-8d6c707f5f5a" />

- inner_eye
<img width="77" alt="Screenshot 2025-06-17 at 1 24 22 AM" src="https://github.com/user-attachments/assets/c21bb175-00c2-4179-a20a-4e505ad37df1" />

- module
<img width="216" alt="Screenshot 2025-06-17 at 1 25 24 AM" src="https://github.com/user-attachments/assets/f670d5fd-e2dc-42cc-9bff-d77a51d65fa1" />

You can create your own designs and pass them through as long as they inherit from the ForgeComponent. If you create your own designs, when you pass them through the config, it will merge them with the default components, so if you only want to change one or two of the components, but not all three, you can!

>[!NOTE]
>More designs are to come, so not every facet of qr code manipulation may be available at this time such as module look aheads/behinds. This is >coming soon.

### Example

This is the code that was used to create the QR Code at the top of the page.

```ruby
QrForge::Forge.build(data: "https://www.github.com/keegankb93/qr_forge",
                     type: :url,
                     config: {
                       qr: { version: 5 },
                       design: {
                         image:,
                         colors: {
                           outer_eye: "#30363D",
                           inner_eye: "#30363D",
                           module: "#484F58"
                         }
                       },
                       output: { size: 250 }
                     })
```

### Roadmap
- Color gradients for outer and inner eyes
- Image background and shape improvements
- More default component selections
