import SwiftUI
import AppKit

class FloatingWindowManager: NSObject, NSWindowDelegate {
    static let shared = FloatingWindowManager()

    private var calculatorWindow: NSWindow?
    private var notesWindow: NSWindow?
    private var ocrWindow: NSWindow?

    func toggleCalculator() {
        if let win = calculatorWindow, win.isVisible {
            win.orderOut(nil)
        } else {
            showCalculator()
        }
    }

    private func showCalculator() {
        if calculatorWindow == nil {
            let view = FloatingCalculatorView()
            calculatorWindow = createFloatingWindow(content: AnyView(view), size: NSSize(width: 250, height: 350))
        }
        centerWindowUnderMouse(calculatorWindow!)
        calculatorWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleNotes() {
        if let win = notesWindow, win.isVisible {
            win.orderOut(nil)
        } else {
            showNotes()
        }
    }

    private func showNotes() {
        if notesWindow == nil {
            let view = FloatingNotesView()
            notesWindow = createFloatingWindow(content: AnyView(view), size: NSSize(width: 300, height: 300))
        }
        centerWindowUnderMouse(notesWindow!)
        notesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleColorPicker() {
        // NSColorSampler is native and simpler
        let sampler = NSColorSampler()
        sampler.show { color in
            guard let color = color else { return }
            // Copy hex to clipboard
            let hex = self.hexString(from: color)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(hex, forType: .string)
            self.showToast("Copied \(hex)")
        }
    }

    func toggleOCR() {
        // Create a full screen transparent window
        if ocrWindow == nil {
            let view = OCRView { text in
                self.ocrWindow?.orderOut(nil)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
                self.showToast("Copied extracted text")
            }

            // Create full screen overlay
            let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
            let win = NSWindow(contentRect: screenRect,
                               styleMask: [.borderless, .fullSizeContentView],
                               backing: .buffered,
                               defer: false)
            win.level = .screenSaver
            win.backgroundColor = .clear
            win.isOpaque = false
            win.hasShadow = false
            win.contentView = NSHostingView(rootView: view)
            ocrWindow = win
        }

        ocrWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showToast(_ message: String) {
        // A simple HUD window that fades out
        let view = Text(message)
            .padding()
            .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
            .cornerRadius(10)
            .shadow(radius: 5)

        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 60),
                           styleMask: [.borderless],
                           backing: .buffered,
                           defer: false)
        win.level = .floating
        win.backgroundColor = .clear
        win.isOpaque = false
        win.contentView = NSHostingView(rootView: view)
        win.center()

        // Position at bottom center
        if let screen = NSScreen.main {
            let frame = screen.visibleFrame
            win.setFrameOrigin(NSPoint(x: frame.midX - 100, y: frame.minY + 100))
        }

        win.makeKeyAndOrderFront(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            win.close()
        }
    }

    private func createFloatingWindow(content: AnyView, size: NSSize) -> NSWindow {
        let win = NSWindow(contentRect: NSRect(origin: .zero, size: size),
                           styleMask: [.titled, .closable, .fullSizeContentView],
                           backing: .buffered,
                           defer: false)
        win.isMovableByWindowBackground = true
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.level = .floating
        win.contentView = NSHostingView(rootView: content)
        return win
    }

    private func centerWindowUnderMouse(_ window: NSWindow) {
        let mouseLoc = NSEvent.mouseLocation
        let winSize = window.frame.size
        let origin = NSPoint(x: mouseLoc.x - winSize.width/2, y: mouseLoc.y - winSize.height/2)
        window.setFrameOrigin(origin)
    }

    private func hexString(from color: NSColor) -> String {
        guard let rgb = color.usingColorSpace(.sRGB) else { return "#000000" }
        return String(format: "#%02X%02X%02X", Int(rgb.redComponent * 255), Int(rgb.greenComponent * 255), Int(rgb.blueComponent * 255))
    }
}
