import SwiftUI

struct SettingsView: View {
    @State private var selection: String? = "general"

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("General") {
                    NavigationLink(value: "general") {
                        Label("General", systemImage: "gear")
                    }
                    NavigationLink(value: "ignored") {
                        Label("Ignored Apps", systemImage: "nosign")
                    }
                }

                Section("Triggers") {
                    NavigationLink(value: "corners") {
                        Label("Corners", systemImage: "rectangle.corners.userfit")
                    }
                    NavigationLink(value: "edges") {
                        Label("Edges", systemImage: "rectangle.dashed")
                    }
                }

                Section("About") {
                    NavigationLink(value: "about") {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Super Corners")
            .listStyle(.sidebar)
        } detail: {
            if let selection = selection {
                switch selection {
                case "general":
                    GeneralSettingsView()
                case "ignored":
                    IgnoredAppsView()
                case "corners":
                    TriggerConfigView(category: .corner)
                case "edges":
                    TriggerConfigView(category: .edge)
                case "about":
                    AboutView()
                default:
                    Text("Select an option")
                }
            } else {
                Text("Select an option")
            }
        }
        .frame(minWidth: 700, minHeight: 450)
    }
}

enum TriggerCategory {
    case corner
    case edge
}
