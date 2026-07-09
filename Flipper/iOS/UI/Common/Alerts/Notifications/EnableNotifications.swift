import Core
import SwiftUI

struct EnableNotificationsAlert: View {
    @EnvironmentObject var theme: AppTheme

    @Binding var isPresented: Bool

    var onEnable: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                ZStack {
                    Image("NotificationsAlert")
                    Image("NotificationsAlertAccent")
                        .renderingMode(.template)
                        .foregroundColor(theme.accent)
                }

                Text("Enable Push Notifications")
                    .font(.system(size: 14, weight: .bold))

                Text("App will notify you about new firmware releases")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 25)

            AlertButtons(
                isPresented: $isPresented,
                text: "Enable",
                cancel: "Skip"
            ) {
                onEnable()
            }
        }
    }
}
