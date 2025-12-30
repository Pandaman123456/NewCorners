import SwiftUI

struct TriggerConfigView: View {
    let category: TriggerCategory
    @ObservedObject var prefs = PreferencesManager.shared

    var triggers: [TriggerType] {
        switch category {
        case .corner:
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        case .edge:
            return [.topEdge, .bottomEdge, .leftEdge, .rightEdge]
        }
    }

    var body: some View {
        Form {
            Section {
                ForEach(triggers) { trigger in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(trigger.name)
                                .frame(width: 100, alignment: .leading)

                            Picker("", selection: binding(for: trigger)) {
                                Text("None").tag(ActionType.none)
                                Divider()

                                Section("System") {
                                    Text("Mission Control").tag(ActionType.missionControl)
                                    Text("Application Windows").tag(ActionType.appWindows)
                                    Text("Show Desktop").tag(ActionType.desktop)
                                    Text("Launchpad").tag(ActionType.launchpad)
                                    Text("Screensaver").tag(ActionType.screensaver)
                                    Text("Lock Screen").tag(ActionType.lockScreen)
                                    Text("Sleep Display").tag(ActionType.sleep)
                                }

                                Section("Media & Display") {
                                    Text("Volume Up").tag(ActionType.volumeUp)
                                    Text("Volume Down").tag(ActionType.volumeDown)
                                    Text("Mute").tag(ActionType.mute)
                                    Text("Brightness Up").tag(ActionType.brightnessUp)
                                    Text("Brightness Down").tag(ActionType.brightnessDown)
                                }

                                Section("Tools") {
                                    Text("Calculator").tag(ActionType.calculator)
                                    Text("Notes").tag(ActionType.notes)
                                    Text("Color Picker").tag(ActionType.colorPicker)
                                    Text("Text Extractor (OCR)").tag(ActionType.ocr)
                                    Text("Dice Roll").tag(ActionType.dice)
                                    Text("Coin Flip").tag(ActionType.coinFlip)
                                    Text("Speak Time").tag(ActionType.time)
                                }

                                Section("AI Actions") {
                                    Text("Send to ChatGPT").tag(ActionType.chatGPT)
                                    Text("Send to Claude").tag(ActionType.claude)
                                    Text("Send to Perplexity").tag(ActionType.perplexity)
                                }

                                Section("Custom") {
                                    Text("Simulate Hotkey").tag(ActionType.simulateHotkey)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        // Show additional config for specific actions
                        if prefs.action(for: trigger) == .simulateHotkey {
                            HStack {
                                Spacer().frame(width: 100)
                                HotkeyRecorder(trigger: trigger)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text(category == .corner ? "Corner Actions" : "Edge Actions")
            } footer: {
                Text("Select an action for each zone.")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func binding(for trigger: TriggerType) -> Binding<ActionType> {
        Binding {
            prefs.action(for: trigger)
        } set: { newValue in
            prefs.setAction(newValue, for: trigger)
        }
    }
}
