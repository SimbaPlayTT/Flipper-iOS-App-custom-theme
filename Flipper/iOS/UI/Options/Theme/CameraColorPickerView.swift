import SwiftUI
import AVFoundation
import PhotosUI

/// Picks an accent color by photographing it: live preview with a center
/// reticle, capture, then the center pixel of the shot is sampled.
/// Falls back to a photo-library picker when no camera is available
/// (e.g. the Simulator).
struct CameraColorPickerView: View {
    @EnvironmentObject var theme: AppTheme
    var onPick: (HSB) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var sampledColor: HSB?
    @State private var authorizationDenied = false
    @State private var photoItem: PhotosPickerItem?

    private var hasCamera: Bool {
        AVCaptureDevice.default(for: .video) != nil
    }

    var body: some View {
        NavigationView {
            Group {
                if let sampledColor {
                    confirmView(sampledColor)
                } else if authorizationDenied {
                    deniedView
                } else if hasCamera {
                    CameraCaptureView(
                        onCapture: { image in
                            sampledColor = image.centerPixelHSB
                        },
                        onDenied: { authorizationDenied = true })
                } else {
                    libraryFallbackView
                }
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func confirmView(_ color: HSB) -> some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.color)
                .frame(width: 96, height: 96)
            Text("#\(color.hexString)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Button("Use this color") {
                onPick(color)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.a1)
            Button("Try again") {
                sampledColor = nil
                photoItem = nil
            }
        }
    }

    private var deniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundColor(.black40)
            Text("Camera access is denied. Allow it in Settings to pick a color from the camera.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private var libraryFallbackView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundColor(.black40)
            Text("No camera available. Pick a photo instead — its center pixel becomes the accent color.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            PhotosPicker("Choose Photo", selection: $photoItem, matching: .images)
                .buttonStyle(.borderedProminent)
                .tint(.a1)
        }
        .onChange(of: photoItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    sampledColor = image.centerPixelHSB
                }
            }
        }
    }
}

// MARK: - AVFoundation capture

private struct CameraCaptureView: View {
    var onCapture: (UIImage) -> Void
    var onDenied: () -> Void

    @StateObject private var camera = CameraController()

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            Circle()
                .strokeBorder(.white, lineWidth: 2)
                .frame(width: 28, height: 28)
                .shadow(radius: 2)

            VStack {
                Spacer()
                Button {
                    camera.capture { image in
                        if let image { onCapture(image) }
                    }
                } label: {
                    Circle()
                        .strokeBorder(.white, lineWidth: 4)
                        .frame(width: 72, height: 72)
                        .background(Circle().fill(.white.opacity(0.3)))
                }
                .padding(.bottom, 32)
            }
        }
        .task {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else {
                onDenied()
                return
            }
            camera.start()
        }
        .onDisappear {
            camera.stop()
        }
    }
}

private class CameraController: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var completion: ((UIImage?) -> Void)?

    func start() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        if let device = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()
        Task.detached { [session] in
            session.startRunning()
        }
    }

    func stop() {
        Task.detached { [session] in
            session.stopRunning()
        }
    }

    func capture(_ completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        output.capturePhoto(
            with: AVCapturePhotoSettings(),
            delegate: self)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image = photo.fileDataRepresentation().flatMap(UIImage.init)
        DispatchQueue.main.async { [completion] in
            completion?(image)
        }
    }
}

private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        var previewLayer: AVCaptureVideoPreviewLayer {
            // swiftlint:disable:next force_cast
            layer as! AVCaptureVideoPreviewLayer
        }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

// MARK: - Center pixel sampling

private extension UIImage {
    var centerPixelHSB: HSB? {
        guard let cgImage else { return nil }
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.draw(
            cgImage,
            in: CGRect(
                x: -CGFloat(cgImage.width) / 2 + 0.5,
                y: -CGFloat(cgImage.height) / 2 + 0.5,
                width: CGFloat(cgImage.width),
                height: CGFloat(cgImage.height)))
        return HSB(color: Color(
            red: Double(pixel[0]) / 255,
            green: Double(pixel[1]) / 255,
            blue: Double(pixel[2]) / 255))
    }
}
