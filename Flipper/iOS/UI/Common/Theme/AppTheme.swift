import SwiftUI

enum SpoofShellColor: String, CaseIterable {
    case white
    case black
    case clear
}

/// Everything the custom theme can change, published as one value so a
/// single `.animation(value:)` covers all of it.
struct ThemeState: Equatable {
    var isCustomAccentEnabled: Bool
    var accentHSB: HSB
    var dpadHue: Double
}

final class AppTheme: ObservableObject {
    static let shared: AppTheme = .init()

    @Published private(set) var state: ThemeState
    @Published var spoofShell: SpoofShellColor? {
        didSet { persistSpoofShell() }
    }

    private let storage: UserDefaults = .standard

    private init() {
        let enabled = storage.bool(forKey: Keys.enabled)
        if enabled {
            state = ThemeState(
                isCustomAccentEnabled: true,
                accentHSB: HSB(
                    hue: storage.double(forKey: Keys.hue),
                    saturation: storage.double(forKey: Keys.saturation),
                    brightness: storage.double(forKey: Keys.brightness)
                ).flooredBrightness,
                dpadHue: storage.double(forKey: Keys.dpadHue))
        } else {
            state = ThemeState(
                isCustomAccentEnabled: false,
                accentHSB: .defaultAccent,
                dpadHue: HSB.defaultAccent.hue)
        }
        let spoofEnabled = storage.bool(forKey: Keys.spoofEnabled)
        let rawColor = storage.string(forKey: Keys.spoofColor) ?? ""
        spoofShell = spoofEnabled ? SpoofShellColor(rawValue: rawColor) : nil
    }

    // MARK: Derived colors

    var accentHSB: HSB { state.accentHSB }

    var accent: Color {
        state.isCustomAccentEnabled
            ? state.accentHSB.color
            : HSB.defaultAccent.color
    }

    var dpadAccentHSB: HSB {
        HSB(
            hue: state.dpadHue,
            saturation: state.accentHSB.saturation,
            brightness: state.accentHSB.brightness)
    }

    var dpadAccent: Color {
        state.isCustomAccentEnabled
            ? dpadAccentHSB.color
            : HSB.defaultAccent.color
    }

    var accentUIColor: UIColor {
        state.isCustomAccentEnabled
            ? state.accentHSB.uiColor
            : HSB.defaultAccent.uiColor
    }

    // MARK: Mutations

    func setCustomAccent(_ accent: HSB, dpadHue: Double) {
        state = ThemeState(
            isCustomAccentEnabled: true,
            accentHSB: accent.flooredBrightness,
            dpadHue: dpadHue)
        persistAccent()
    }

    func resetToDefault() {
        state = ThemeState(
            isCustomAccentEnabled: false,
            accentHSB: .defaultAccent,
            dpadHue: HSB.defaultAccent.hue)
        persistAccent()
    }

    private func persistAccent() {
        storage.set(state.isCustomAccentEnabled, forKey: Keys.enabled)
        storage.set(state.accentHSB.hue, forKey: Keys.hue)
        storage.set(state.accentHSB.saturation, forKey: Keys.saturation)
        storage.set(state.accentHSB.brightness, forKey: Keys.brightness)
        storage.set(state.dpadHue, forKey: Keys.dpadHue)
    }

    private func persistSpoofShell() {
        storage.set(spoofShell != nil, forKey: Keys.spoofEnabled)
        if let spoofShell {
            storage.set(spoofShell.rawValue, forKey: Keys.spoofColor)
        }
    }

    private enum Keys {
        static let enabled = "customAccentThemeEnabled"
        static let hue = "customAccentHue"
        static let saturation = "customAccentSaturation"
        static let brightness = "customAccentBrightness"
        static let dpadHue = "customDPadAccentHue"
        static let spoofEnabled = "spoofShellEnabled"
        static let spoofColor = "spoofShellColor"
    }
}
