import SwiftUI
import Peripheral

extension RemoteControlView {
    struct DeviceControls: View {
        var action: (InputKey, Bool) -> Void

        var body: some View {
            HStack(alignment: .bottom, spacing: 36) {
                ControlCircle(action: action)
                ControlBackButton { action(.back, $0) }
            }
        }
    }

    struct ControlCircle: View {
        @EnvironmentObject var theme: AppTheme

        var action: @MainActor (InputKey, Bool) -> Void

        var verticalSpacing: Double { 12 }
        var horizontalSpacing: Double { 10 }

        var contentPadding: Double { 14 }

        var body: some View {
            ZStack {
                Image("RemoteControlBackgroundAccent")
                    .foregroundColor(theme.dpadAccent)
                Image("RemoteControlBackgroundDetail")
            }
            .overlay {
                    VStack(spacing: verticalSpacing) {
                        HStack(spacing: horizontalSpacing) {
                            ControlButton(inputKey: .up) {
                                action(.up, $0)
                            }
                        }

                        HStack(spacing: horizontalSpacing) {
                            ControlButton(inputKey: .left) {
                                action(.left, $0)
                            }
                            ControlButton(inputKey: .enter) {
                                action(.enter, $0)
                            }
                            ControlButton(inputKey: .right) {
                                action(.right, $0)
                            }
                        }

                        HStack(spacing: horizontalSpacing) {
                            ControlButton(inputKey: .down) {
                                action(.down, $0)
                            }
                        }
                    }
                }
        }
    }

    struct ControlButtonImage: View {
        let inputKey: InputKey

        var rotation: Double {
            switch inputKey {
            case .up: return 0
            case .left: return -90
            case .right: return 90
            case .down: return 180
            default: return 0
            }
        }

        var image: String {
            switch inputKey {
            case .up: return "RemoteControlArrow"
            case .down: return "RemoteControlArrow"
            case .left: return "RemoteControlArrow"
            case .right: return "RemoteControlArrow"
            case .enter: return "RemoteControlEnter"
            case .back: return "RemoteControlBack"
            }
        }

        init(_ inputKey: InputKey) {
            self.inputKey = inputKey
        }

        @EnvironmentObject var theme: AppTheme

        var body: some View {
            ZStack {
                Image("\(image)Accent")
                    .foregroundColor(theme.dpadAccent)
                Image("\(image)Detail")
            }
            .rotationEffect(.degrees(rotation))
        }
    }

    struct ControlButton: View {
        let inputKey: InputKey
        var action: (Bool) -> Void

        @State private var longPressTask: Task<Void, Never>?
        @State private var didFireLongPress = false

        var body: some View {
            Button {
            } label: {
                ControlButtonImage(inputKey)
            }
            .highPriorityGesture(
                PressGesture.make(
                    longPressTask: $longPressTask,
                    didFireLongPress: $didFireLongPress,
                    action: action)
            )
        }
    }

    struct ControlEnterButton: View {
        @EnvironmentObject var theme: AppTheme

        var action: (Bool) -> Void

        @State private var longPressTask: Task<Void, Never>?
        @State private var didFireLongPress = false

        var body: some View {
            Button {
            } label: {
                ZStack {
                    Image("RemoteControlEnterAccent")
                        .foregroundColor(theme.dpadAccent)
                    Image("RemoteControlEnterDetail")
                }
            }
            .highPriorityGesture(
                PressGesture.make(
                    longPressTask: $longPressTask,
                    didFireLongPress: $didFireLongPress,
                    action: action)
            )
        }
    }

    struct ControlBackButton: View {
        @EnvironmentObject var theme: AppTheme

        var action: (Bool) -> Void

        @State private var longPressTask: Task<Void, Never>?
        @State private var didFireLongPress = false

        var body: some View {
            Button {
            } label: {
                // Accent disc (template, tinted) under the original
                // black outline + glyph so the detail stays visible.
                ZStack {
                    Image("RemoteControlBackAccent")
                        .foregroundColor(theme.dpadAccent)
                    Image("RemoteControlBackDetail")
                }
            }
            .highPriorityGesture(
                PressGesture.make(
                    longPressTask: $longPressTask,
                    didFireLongPress: $didFireLongPress,
                    action: action)
            )
        }
    }
}

/// Fires immediately on touch-down/touch-up instead of waiting on
/// `TapGesture`/`LongPressGesture` recognition, which measurably lags
/// behind raw touch events for rapid D-Pad input.
private enum PressGesture {
    static func make(
        longPressTask: Binding<Task<Void, Never>?>,
        didFireLongPress: Binding<Bool>,
        action: @escaping (Bool) -> Void
    ) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard longPressTask.wrappedValue == nil else { return }
                didFireLongPress.wrappedValue = false
                longPressTask.wrappedValue = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    guard !Task.isCancelled else { return }
                    didFireLongPress.wrappedValue = true
                    action(true)
                }
            }
            .onEnded { _ in
                longPressTask.wrappedValue?.cancel()
                longPressTask.wrappedValue = nil
                if !didFireLongPress.wrappedValue {
                    action(false)
                }
            }
    }
}
