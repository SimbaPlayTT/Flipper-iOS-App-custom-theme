import SwiftUI
import Peripheral

extension RemoteControlView {
    struct DeviceScreen<Content: View>: View {
        @EnvironmentObject var theme: AppTheme

        let content: () -> Content

        init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content
        }

        var body: some View {
            Image("RemoteScreen")
                .resizable()
                .scaledToFit()
                .foregroundColor(theme.accent)
                .overlay(
                    GeometryReader { proxy in
                        content()
                            .padding(proxy.size.width * 0.04)
                    }
                )
        }
    }
}
