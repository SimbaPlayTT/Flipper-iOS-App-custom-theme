# Flipper iOS App — Custom Theme Edition ("Flipper CT")

A fork of the official [Flipper Devices iOS app](https://github.com/flipperdevices/Flipper-iOS-App) with a **global custom accent color** feature added — the iOS counterpart of the [Flipper-Android-App-custom-theme](https://github.com/SimbaPlayTT/Flipper-Android-App-custom-theme) fork.

## What's new

- **Options → Custom Theme**: a color picker with 12 preset swatches, Hue / Saturation / Brightness sliders, an independent D-Pad hue slider, a bare-`RRGGBB` hex field, Reset and Done.
- **Camera color picker**: photograph any object and its center pixel becomes the accent color (brightness is forced to full — camera exposure makes sampled brightness unreliable). Falls back to a photo-library picker when no camera is available (e.g. the Simulator).
- **Spoof Shell**: override the Flipper mockup's body color (White / Black / Transparent) regardless of what the connected device reports.
- The chosen color persists across restarts and animates smoothly (750 ms) wherever it's applied.
- Recolored surfaces: navigation bars, toggles, primary buttons, the Remote Control D-Pad (disc + arrows + OK + Back button fill), the "FLIPPER" wordmark, the streamed-screen bezel, the simulated Flipper LCD background (live view *and* screenshots), and the Device Info mockup's accent details (bezel, mini D-pad, wordmark).
- Deliberately left alone: the per-protocol category colors (NFC / RFID / Sub-GHz / iButton / Infrared / BadUSB keep their identity colors), the secondary blue accent, and the mockup's case color itself.
- Brightness is floored at 0.25 so the accent can never go near-black — the D-Pad uses the accent as both its disc background and its glyph fill.
- **Rebrand**: app name "Flipper CT", purple-gradient app icon, own bundle id (`com.simba.flipperct`) and app group so it installs alongside the official app.

## Building

Xcode 16+ (tested with Xcode 26.5), iOS 16.0+ deployment target.

```
open Flipper/Flipper.xcodeproj
```

Or from the command line:

```
cd Flipper
xcodebuild -project Flipper.xcodeproj -scheme "Flipper(iOS)" \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

To run on a real device, set your own development team on the app (and widget) targets in *Signing & Capabilities*. App groups require a paid developer account; if you don't have one, remove the App Groups capability and the widget extensions.

### Note on package pins

Upstream pins the `swiftstack` packages (`radix`, `dcompression`) to branch `dev`; that repo family rewrote history and now requires Swift tools 6.4. `Package.resolved` here pins the last Swift-6.0-compatible revisions so the project builds out of the box.

## License

MIT, same as upstream.
