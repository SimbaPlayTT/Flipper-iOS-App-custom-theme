import SwiftUI

struct FlipperTemplate: View {
    @Environment(\.flipperStyle) var style
    @Environment(\.flipperState) var state
    @EnvironmentObject var theme: AppTheme

    enum Style: String {
        case white
        case black
        case clear
    }

    enum State: String {
        case normal
        case disabled
    }

    // The spoofed shell color (if any) wins over whatever the
    // connected device reports.
    var effectiveStyle: Style {
        switch theme.spoofShell {
        case .white: return .white
        case .black: return .black
        case .clear: return .clear
        case nil: return style
        }
    }

    var imageName: String {
        "FZ\(effectiveStyle.rawValue.capitalized)\(state.rawValue.capitalized)"
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .overlay {
                // Redraws only the accent paths (bezel, mini D-pad,
                // FLIPPER wordmark) in the custom accent color; the
                // case color stays untouched. Disabled variants are
                // gray and never accent-tinted.
                if theme.state.isCustomAccentEnabled, state == .normal {
                    Image("\(imageName)Accent")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(theme.accent)
                }
            }
    }
}
