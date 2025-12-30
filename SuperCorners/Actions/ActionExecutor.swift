import Cocoa
import SwiftUI
import Carbon

class ActionExecutor {
    static let shared = ActionExecutor()

    // Dependencies
    let floatingManager = FloatingWindowManager.shared

    func execute(_ action: ActionType, trigger: TriggerType? = nil) {
        print("Executing Action: \(action)")

        switch action {
        // System
        case .missionControl:
            performSystemAction(selector: Selector(("missionControl:")))
        case .appWindows:
            performSystemAction(selector: Selector(("applicationWindows:")))
        case .desktop:
            performSystemAction(selector: Selector(("showDesktop:")))
        case .launchpad:
            performSystemAction(selector: Selector(("showLaunchpad:")))
        case .screensaver:
            startScreensaver()
        case .lockScreen:
            lockScreen()
        case .sleep:
            sleepDisplay()

        // Volume
        case .volumeUp:
            simulateMediaKey(NX_KEYTYPE_SOUND_UP)
        case .volumeDown:
            simulateMediaKey(NX_KEYTYPE_SOUND_DOWN)
        case .mute:
            simulateMediaKey(NX_KEYTYPE_MUTE)

        // Brightness
        case .brightnessUp:
            simulateMediaKey(NX_KEYTYPE_BRIGHTNESS_UP)
        case .brightnessDown:
            simulateMediaKey(NX_KEYTYPE_BRIGHTNESS_DOWN)

        // Tools
        case .calculator:
            floatingManager.toggleCalculator()
        case .notes:
            floatingManager.toggleNotes()
        case .colorPicker:
            floatingManager.toggleColorPicker()
        case .ocr:
            floatingManager.toggleOCR()
        case .dice:
            showToast(message: "🎲 Rolled a \(Int.random(in: 1...6))")
        case .coinFlip:
            showToast(message: Bool.random() ? "🪙 Heads" : "🪙 Tails")
        case .time:
            speakTime()

        // AI
        case .chatGPT:
            runAppleScript(AIScripts.chatGPT)
        case .claude:
            runAppleScript(AIScripts.claude)
        case .perplexity:
            runAppleScript(AIScripts.perplexity)

        case .simulateHotkey:
            if let trigger = trigger {
                simulateHotkey(for: trigger)
            }

        case .none:
            break
        }
    }

    // MARK: - Hotkeys

    private func simulateHotkey(for trigger: TriggerType) {
        guard let val = PreferencesManager.shared.getParameter(key: "hotkey", for: trigger) else { return }
        let parts = val.components(separatedBy: "|")
        if parts.count >= 3,
           let keyCode = Int(parts[1]),
           let modifiersRaw = UInt(parts[2]) {

            let source = CGEventSource(stateID: .hidSystemState)
            let flags = CGEventFlags(rawValue: UInt64(modifiersRaw))

            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: true)
            keyDown?.flags = flags
            keyDown?.post(tap: .cghidEventTap)

            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: false)
            keyUp?.flags = flags
            keyUp?.post(tap: .cghidEventTap)
        }
    }

    // MARK: - System Actions

    private func performSystemAction(selector: Selector) {
        switch selector.description {
        case "missionControl:":
            runShell("open -a 'Mission Control'")
        case "showDesktop:":
             runShell("open -a 'Mission Control'") // Toggling MC often shows desktop if done right, but actually F11 is better.
             // Simulating F11 (Keycode 103)
             simulateKey(103)
        case "applicationWindows:":
             runShell("open -a 'Mission Control' --args 2")
        case "showLaunchpad:":
             runShell("open -a 'Launchpad'")
        default:
            break
        }
    }

    private func startScreensaver() {
        runShell("open -a ScreenSaverEngine")
    }

    private func lockScreen() {
        let source = "tell application \"System Events\" to keystroke \"q\" using {command down, control down}"
        runAppleScript(source)
    }

    private func sleepDisplay() {
        runShell("pmset displaysleepnow")
    }

    // MARK: - Media Keys

    private func simulateMediaKey(_ key: Int32) {
        func doKey(down: Bool) {
            let flags = NSEvent.ModifierFlags(rawValue: (down ? 0xa00 : 0xb00))
            let data1 = Int((key << 16) | (down ? 0xa00 : 0xb00))

            let ev = NSEvent.otherEvent(with: .systemDefined,
                                        location: NSPoint(x: 0, y: 0),
                                        modifierFlags: flags,
                                        timestamp: 0,
                                        windowNumber: 0,
                                        context: nil,
                                        subtype: 8,
                                        data1: data1,
                                        data2: -1)
            let cgEv = ev?.cgEvent
            cgEv?.post(tap: .cghidEventTap)
        }

        doKey(down: true)
        doKey(down: false)
    }

    private func simulateKey(_ keyCode: CGKeyCode) {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    // MARK: - Helpers

    private func runShell(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        task.launch()
    }

    private func runAppleScript(_ source: String) {
        if let script = NSAppleScript(source: source) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript Error: \(error)")
            }
        }
    }

    private func speakTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: Date())

        let synth = NSSpeechSynthesizer()
        synth.startSpeaking(timeString)
    }

    private func showToast(message: String) {
        FloatingWindowManager.shared.showToast(message)
    }
}

// Placeholder for FloatingWindowManager
// (Assuming the file exists in Actions/FloatingWindows/FloatingWindowManager.swift)

struct AIScripts {
    static let chatGPT = """
    tell application "System Events"
        keystroke "c" using {command down}
        delay 0.2
        tell application "ChatGPT" to activate
        delay 1.0
        keystroke "v" using {command down}
        delay 0.2
        key code 36
    end tell
    """

    static let claude = """
    tell application "System Events"
        keystroke "c" using {command down}
        delay 0.2
        tell application "Claude" to activate
        delay 1.0
        keystroke "v" using {command down}
        delay 0.2
        key code 36
    end tell
    """

    static let perplexity = """
    tell application "System Events"
        keystroke "c" using {command down}
        delay 0.2
        tell application "Perplexity" to activate
        delay 1.0
        keystroke "v" using {command down}
        delay 0.2
        key code 36
    end tell
    """
}
