import SwiftUI

@MainActor
class ThemeColorPickerViewModel: ObservableObject {
    struct Draft: Equatable {
        var hue: Double
        var saturation: Double
        var brightness: Double
        var dpadHue: Double

        var accent: HSB {
            .init(hue: hue, saturation: saturation, brightness: brightness)
        }

        var dpadAccent: HSB {
            .init(hue: dpadHue, saturation: saturation, brightness: brightness)
        }

        static var `default`: Draft {
            let hsb = HSB.defaultAccent
            return .init(
                hue: hsb.hue,
                saturation: hsb.saturation,
                brightness: hsb.brightness,
                dpadHue: hsb.hue)
        }
    }

    @Published private(set) var draft: Draft

    private let theme: AppTheme

    init(theme: AppTheme = .shared) {
        self.theme = theme
        if theme.state.isCustomAccentEnabled {
            let accent = theme.state.accentHSB
            draft = .init(
                hue: accent.hue,
                saturation: accent.saturation,
                brightness: max(accent.brightness, HSB.minAccentBrightness),
                dpadHue: theme.state.dpadHue)
        } else {
            draft = .default
        }
    }

    func updateHue(_ hue: Double) {
        draft.hue = hue
        commitDraft()
    }

    func updateSaturation(_ saturation: Double) {
        draft.saturation = saturation
        commitDraft()
    }

    func updateBrightness(_ brightness: Double) {
        draft.brightness = max(brightness, HSB.minAccentBrightness)
        commitDraft()
    }

    func updateDPadHue(_ dpadHue: Double) {
        draft.dpadHue = dpadHue
        commitDraft()
    }

    func selectPreset(hue: Double) {
        apply(.init(hue: hue, saturation: 1, brightness: 1))
    }

    @discardableResult
    func applyHex(_ hex: String) -> Bool {
        guard let hsb = HSB(hexString: hex) else { return false }
        apply(hsb)
        return true
    }

    /// Camera exposure and ambient lighting make photographed brightness
    /// unreliable, so only hue/saturation from the sample are trusted and
    /// brightness is forced to full.
    func applyCameraColor(_ hsb: HSB) {
        apply(.init(hue: hsb.hue, saturation: hsb.saturation, brightness: 1))
    }

    private func apply(_ hsb: HSB) {
        let floored = hsb.flooredBrightness
        draft = .init(
            hue: floored.hue,
            saturation: floored.saturation,
            brightness: floored.brightness,
            dpadHue: floored.hue)
        commitDraft()
    }

    func commitDraft() {
        withAnimation(.easeInOut(duration: 0.75)) {
            theme.setCustomAccent(draft.accent, dpadHue: draft.dpadHue)
        }
    }

    func resetToDefault() {
        draft = .default
        withAnimation(.easeInOut(duration: 0.75)) {
            theme.resetToDefault()
        }
    }
}
