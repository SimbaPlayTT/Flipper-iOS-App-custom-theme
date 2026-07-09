import SwiftUI
import Peripheral

struct FlipperDetectReaderImage: View {
    @EnvironmentObject var theme: AppTheme

    var body: some View {
        ZStack {
            FlipperTemplate()

            Image("FZDetectReaderContent")
                .resizable()
                .scaledToFit()

            Image("FZDetectReaderContentAccent")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(theme.accent)
        }
    }
}
