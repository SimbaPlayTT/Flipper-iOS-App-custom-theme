import SwiftUI

struct OutdatedMobileCard: View {
    @EnvironmentObject var theme: AppTheme

    @Environment(\.openURL) private var openURL

    var body: some View {
        Card {
            VStack(spacing: 0) {
                ZStack {
                    Image("OutdatedMobile")
                    Image("OutdatedMobileAccent")
                        .renderingMode(.template)
                        .foregroundColor(theme.accent)
                }

                Text("Outdated Mobile App Version")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Text(
                    "Update the app to the latest version to connect to Flipper"
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.top, 2)

                Button {
                    openURL(.appStore)
                } label: {
                    Text("Go to App Store")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.a2)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
        }
    }
}
