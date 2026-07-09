import SwiftUI

extension RemoteControlView {
    struct LockButton: View {
        @EnvironmentObject var theme: AppTheme

        let isLocked: Bool
        let action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Button {
                    action()
                } label: {
                    Image(isLocked ? "RemoteUnlock" : "RemoteLock")
                        .foregroundColor(theme.accent)
                }

                ZStack {
                    Text("Lock Flipper")
                        .opacity(isLocked ? 0 : 1)

                    Text("Unlock Flipper")
                        .opacity(isLocked ? 1 : 0)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.a1)
            }
        }
    }
}
