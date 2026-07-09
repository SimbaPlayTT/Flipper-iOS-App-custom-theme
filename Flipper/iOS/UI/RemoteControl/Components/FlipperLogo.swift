import SwiftUI

extension RemoteControlView {
    struct FlipperLogo: View {
        @EnvironmentObject var theme: AppTheme

        var body: some View {
            Image("RemoteFlipperLogo")
                .resizable()
                .scaledToFit()
                .foregroundColor(theme.accent)
        }
    }
}
