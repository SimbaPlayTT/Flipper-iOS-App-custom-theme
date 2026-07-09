import SwiftUI

extension RemoteControlView {
    struct ScreenshotButton: View {
        @EnvironmentObject var theme: AppTheme

        var action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Button {
                    action()
                } label: {
                    Image("RemoteScreenshot")
                        .foregroundColor(theme.accent)
                }
                Text("Screenshot")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.a1)
            }
        }
    }
}
