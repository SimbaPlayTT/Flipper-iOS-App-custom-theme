import SwiftUI

struct ThemeColorPickerView: View {
    @StateObject var viewModel: ThemeColorPickerViewModel = .init()
    @EnvironmentObject var theme: AppTheme
    @Environment(\.dismiss) private var dismiss

    @State private var hexText: String = ""
    @State private var showHexError = false
    @State private var showCameraPicker = false

    private static let presetHues: [Double] = stride(from: 0, to: 360, by: 30)
        .map { Double($0) }

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.draft.accent.color)
                        .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("#\(viewModel.draft.accent.hexString)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                        Text("Current accent color")
                            .font(.system(size: 12))
                            .foregroundColor(.black40)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("Presets")) {
                VStack(spacing: 12) {
                    ForEach([Array(Self.presetHues.prefix(6)),
                             Array(Self.presetHues.suffix(6))], id: \.first) { row in
                        HStack(spacing: 0) {
                            ForEach(row, id: \.self) { hue in
                                let color = HSB(hue: hue, saturation: 1, brightness: 1)
                                Button {
                                    viewModel.selectPreset(hue: hue)
                                    hexText = ""
                                } label: {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 34, height: 34)
                                        .overlay {
                                            if isSelectedPreset(hue: hue) {
                                                Circle().strokeBorder(
                                                    Color.primary,
                                                    lineWidth: 2)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section {
                sliderRow("HUE", gradient: hueGradient) {
                    GradientSlider(
                        value: Binding(
                            get: { viewModel.draft.hue },
                            set: { viewModel.updateHue($0) }),
                        range: 0...360,
                        gradient: hueGradient)
                }
                sliderRow("SATURATION", gradient: saturationGradient) {
                    GradientSlider(
                        value: Binding(
                            get: { viewModel.draft.saturation },
                            set: { viewModel.updateSaturation($0) }),
                        range: 0...1,
                        gradient: saturationGradient)
                }
                sliderRow("BRIGHTNESS", gradient: brightnessGradient) {
                    GradientSlider(
                        value: Binding(
                            get: { viewModel.draft.brightness },
                            set: { viewModel.updateBrightness($0) }),
                        range: HSB.minAccentBrightness...1,
                        gradient: brightnessGradient)
                }
                sliderRow("D-PAD", gradient: hueGradient) {
                    GradientSlider(
                        value: Binding(
                            get: { viewModel.draft.dpadHue },
                            set: { viewModel.updateDPadHue($0) }),
                        range: 0...360,
                        gradient: hueGradient)
                }
            }

            Section {
                HStack {
                    Text("HEX")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black40)
                    TextField("FF8200", text: $hexText)
                        .font(.system(size: 16, design: .monospaced))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onSubmit { applyHex() }
                    Button("Apply") { applyHex() }
                        .buttonStyle(.borderless)
                        .disabled(hexText.isEmpty)
                }
                if showHexError {
                    Text("Enter a 6-digit hex code, e.g. 589DFF")
                        .font(.system(size: 12))
                        .foregroundColor(.sRed)
                }
                Button {
                    showCameraPicker = true
                } label: {
                    Label("Camera", systemImage: "camera")
                }
            }

            Section(header: Text("Spoof Shell")) {
                Picker("Shell color", selection: spoofSelection) {
                    Text("Auto").tag("auto")
                    Text("White").tag(SpoofShellColor.white.rawValue)
                    Text("Black").tag(SpoofShellColor.black.rawValue)
                    Text("Transparent").tag(SpoofShellColor.clear.rawValue)
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button("Reset") {
                    viewModel.resetToDefault()
                    hexText = ""
                    showHexError = false
                }
                .foregroundColor(.sRed)
                Button("Done") {
                    viewModel.commitDraft()
                    dismiss()
                }
            }
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Custom Theme")
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraColorPickerView { hsb in
                viewModel.applyCameraColor(hsb)
                hexText = ""
            }
        }
    }

    private func isSelectedPreset(hue: Double) -> Bool {
        abs(viewModel.draft.hue - hue) < 0.5 &&
        viewModel.draft.saturation == 1 &&
        viewModel.draft.brightness == 1
    }

    private func applyHex() {
        let applied = viewModel.applyHex(hexText)
        showHexError = !applied
    }

    private var spoofSelection: Binding<String> {
        Binding(
            get: { theme.spoofShell?.rawValue ?? "auto" },
            set: { theme.spoofShell = SpoofShellColor(rawValue: $0) })
    }

    private var hueGradient: Gradient {
        Gradient(colors: (0...12).map {
            HSB(hue: Double($0) * 30, saturation: 1, brightness: 1).color
        })
    }

    private var saturationGradient: Gradient {
        Gradient(colors: [
            HSB(hue: viewModel.draft.hue, saturation: 0, brightness: 1).color,
            HSB(hue: viewModel.draft.hue, saturation: 1, brightness: 1).color
        ])
    }

    private var brightnessGradient: Gradient {
        Gradient(colors: [
            HSB(
                hue: viewModel.draft.hue,
                saturation: viewModel.draft.saturation,
                brightness: HSB.minAccentBrightness).color,
            HSB(
                hue: viewModel.draft.hue,
                saturation: viewModel.draft.saturation,
                brightness: 1).color
        ])
    }

    @ViewBuilder
    private func sliderRow(
        _ title: String,
        gradient: Gradient,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black40)
            content()
        }
        .padding(.vertical, 4)
    }
}

struct GradientSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let gradient: Gradient

    private let trackHeight: CGFloat = 12
    private let thumbSize: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let fraction = (value - range.lowerBound)
                / (range.upperBound - range.lowerBound)
            let x = fraction * (width - thumbSize) + thumbSize / 2

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(
                        gradient: gradient,
                        startPoint: .leading,
                        endPoint: .trailing))
                    .frame(height: trackHeight)
                Circle()
                    .fill(.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(radius: 2)
                    .position(x: x, y: geometry.size.height / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let fraction = (drag.location.x - thumbSize / 2)
                            / (width - thumbSize)
                        let clamped = min(max(fraction, 0), 1)
                        value = range.lowerBound
                            + clamped * (range.upperBound - range.lowerBound)
                    }
            )
        }
        .frame(height: thumbSize)
    }
}
