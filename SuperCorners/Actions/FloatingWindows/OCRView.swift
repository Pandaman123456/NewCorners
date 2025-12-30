import SwiftUI
import Vision

struct OCRView: View {
    @State private var overlayRect: CGRect = .zero
    @State private var isSelecting = false
    @State private var selectionStart: CGPoint = .zero
    @State private var selectionEnd: CGPoint = .zero

    // This view is meant to be a full screen overlay
    var onComplete: ((String) -> Void)?

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isSelecting {
                                selectionStart = value.startLocation
                                isSelecting = true
                            }
                            selectionEnd = value.location
                        }
                        .onEnded { value in
                            isSelecting = false
                            captureAndProcess(rect: selectionRect)
                        }
                )

            if isSelecting {
                Path { path in
                    path.addRect(selectionRect)
                }
                .stroke(Color.white, lineWidth: 2)
                .background(Path { path in
                    path.addRect(selectionRect)
                }.fill(Color.white.opacity(0.2)))
            }

            Text("Click and drag to select text")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .position(x: NSScreen.main?.frame.midX ?? 400, y: 100)
        }
    }

    var selectionRect: CGRect {
        let x = min(selectionStart.x, selectionEnd.x)
        let y = min(selectionStart.y, selectionEnd.y)
        let w = abs(selectionStart.x - selectionEnd.x)
        let h = abs(selectionStart.y - selectionEnd.y)
        return CGRect(x: x, y: y, width: w, height: h)
    }

    func captureAndProcess(rect: CGRect) {
        // Hide overlay first? No, we need to capture screen.
        // Actually we need to remove this window from the screenshot or capture underneath.
        // For simplicity, we just grab the screen image.

        // This requires Screen Recording permission usually.
        guard let cgImage = CGWindowListCreateImage(rect, .optionOnScreenBelowWindow, kCGNullWindowID, .bestResolution) else {
            return
        }

        recognizeText(from: cgImage)
    }

    func recognizeText(from image: CGImage) {
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")

            DispatchQueue.main.async {
                onComplete?(text)
            }
        }

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
}
