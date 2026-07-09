import SwiftUI

extension ShareView {
    struct ShareAsFileButton: View {
        @EnvironmentObject var theme: AppTheme

        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                VStack(spacing: 12) {
                    Image("ShareAsFile")
                        .foregroundColor(theme.accent)
                    Text("Export File")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.a1)
                }
            }
        }
    }
}
