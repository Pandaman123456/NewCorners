import SwiftUI
import Carbon

struct HotkeyRecorder: View {
    let trigger: TriggerType
    @ObservedObject var prefs = PreferencesManager.shared
    @State private var isRecording = false
    @State private var currentEventMon: Any?

    var savedHotkeyDisplay: String {
        guard let val = prefs.getParameter(key: "hotkey", for: trigger) else { return "None" }
        let parts = val.components(separatedBy: "|")
        return parts.first ?? "None"
    }

    var body: some View {
        HStack {
            Text(savedHotkeyDisplay)
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)

            Button(isRecording ? "Press Key..." : "Record") {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }
        }
    }

    func startRecording() {
        isRecording = true
        // Monitor local events to catch the keypress
        currentEventMon = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags
            let keyCode = event.keyCode

            let char = event.charactersIgnoringModifiers ?? "?"
            let displayStr = hotkeyString(modifiers: modifiers, char: char)

            // Format: "DisplayString|KeyCode|Modifiers"
            let storageValue = "\(displayStr)|\(keyCode)|\(modifiers.rawValue)"
            prefs.setParameter(storageValue, key: "hotkey", for: trigger)

            stopRecording()
            return nil // Consume event
        }
    }

    func stopRecording() {
        isRecording = false
        if let mon = currentEventMon {
            NSEvent.removeMonitor(mon)
            currentEventMon = nil
        }
    }

    func hotkeyString(modifiers: NSEvent.ModifierFlags, char: String) -> String {
        var str = ""
        if modifiers.contains(.command) { str += "⌘" }
        if modifiers.contains(.control) { str += "⌃" }
        if modifiers.contains(.option) { str += "⌥" }
        if modifiers.contains(.shift) { str += "⇧" }
        str += char.uppercased()
        return str
    }
}
