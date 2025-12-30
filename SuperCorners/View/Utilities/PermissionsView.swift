import SwiftUI
import ApplicationServices

struct PermissionsView: View {
    @State private var hasPermission = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Permissions Required")
                .font(.title2)
                .fontWeight(.bold)

            Text("Super Corners needs Accessibility permissions to track your mouse and trigger actions.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if hasPermission {
                Text("Permission Granted! 🎉")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            } else {
                Button("Open System Settings") {
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                    NSWorkspace.shared.open(url)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .onReceive(timer) { _ in
            checkPermission()
        }
    }

    func checkPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        hasPermission = accessEnabled
    }
}
