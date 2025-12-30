import SwiftUI

struct IgnoredAppsView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    @State private var runningApps: [NSRunningApplication] = []

    var body: some View {
        VStack {
            Text("Ignored Applications")
                .font(.headline)
            Text("Select applications to disable Super Corners when they are active.")
                .font(.caption)
                .foregroundStyle(.secondary)

            List {
                ForEach(runningApps, id: \.bundleIdentifier) { app in
                    HStack {
                        if let icon = app.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Text(app.localizedName ?? "Unknown")
                        Spacer()
                        if isIgnored(app) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleIgnored(app)
                    }
                }
            }
            .onAppear {
                refreshApps()
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: refreshApps) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    func refreshApps() {
        // Filter for apps that appear in dock or have windows
        runningApps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }.sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    func isIgnored(_ app: NSRunningApplication) -> Bool {
        guard let id = app.bundleIdentifier else { return false }
        return prefs.ignoredApps.contains(id)
    }

    func toggleIgnored(_ app: NSRunningApplication) {
        guard let id = app.bundleIdentifier else { return }
        var list = prefs.ignoredApps
        if list.contains(id) {
            list.removeAll { $0 == id }
        } else {
            list.append(id)
        }
        prefs.ignoredApps = list
    }
}
