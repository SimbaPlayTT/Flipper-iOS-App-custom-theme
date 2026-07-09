import SwiftUI

/// Hue in degrees (0..360), saturation/brightness in 0..1.
struct HSB: Equatable {
    var hue: Double
    var saturation: Double
    var brightness: Double

    /// Accent brightness floor: the D-Pad uses the accent as both its disc
    /// background and its glyph fill, so a near-black accent would render as
    /// a solid black disc with invisible glyphs.
    static let minAccentBrightness: Double = 0.25

    static let defaultAccent: HSB = .init(color: .init(red: 1.0, green: 0.51, blue: 0.0))

    var color: Color {
        Color(hue: hue / 360, saturation: saturation, brightness: brightness)
    }

    var uiColor: UIColor {
        UIColor(
            hue: hue / 360,
            saturation: saturation,
            brightness: brightness,
            alpha: 1)
    }

    var flooredBrightness: HSB {
        var copy = self
        copy.brightness = max(brightness, Self.minAccentBrightness)
        return copy
    }

    init(hue: Double, saturation: Double, brightness: Double) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
    }

    init(color: Color) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(color).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        self.init(hue: h * 360, saturation: s, brightness: b)
    }

    /// Parses a bare RRGGBB hex string (case insensitive, optional "#").
    init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let value = UInt32(hex, radix: 16) else {
            return nil
        }
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(color: Color(red: red, green: green, blue: blue))
    }

    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(
            format: "%02X%02X%02X",
            Int(round(red * 255)),
            Int(round(green * 255)),
            Int(round(blue * 255)))
    }
}
