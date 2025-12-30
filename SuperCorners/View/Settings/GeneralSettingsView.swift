import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var mouseMonitor = MouseMonitor.shared
    @AppStorage("launchAtLogin") var launchAtLogin = false

    var body: some View {
        Form {
            Section("App Behavior") {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .disabled(true) // Requires helper app implementation, placeholder
                    .help("Not implemented in this demo")
            }

            Section("Sensitivity") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Corner Sensitivity")
                        Spacer()
                        Text("\(Int(mouseMonitor.cornerSensitivity)) px")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $mouseMonitor.cornerSensitivity, in: 1...50, step: 1)
                    Text("How large the corner area is.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Edge Sensitivity")
                        Spacer()
                        Text("\(Int(mouseMonitor.edgeSensitivity)) px")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $mouseMonitor.edgeSensitivity, in: 1...50, step: 1)
                    Text("How thick the edge area is.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Trigger Delay")
                        Spacer()
                        Text(String(format: "%.2f s", mouseMonitor.triggerDelay))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $mouseMonitor.triggerDelay, in: 0...2.0, step: 0.05)
                    Text("How long the mouse must stay to trigger.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
