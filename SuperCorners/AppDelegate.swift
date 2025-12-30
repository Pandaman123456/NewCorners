import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var settingsWindowController: NSWindowController?
    var permissionsWindowController: NSWindowController?

    // Core Managers
    let mouseMonitor = MouseMonitor.shared
    let actionExecutor = ActionExecutor.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup Status Bar Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: "Super Corners")
        }
        setupMenu()

        // Check permissions first
        checkPermissions()

        // Ensure app does not show in dock
        NSApp.setActivationPolicy(.accessory)
    }

    func checkPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : false] // Don't prompt system alert yet
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if accessEnabled {
            mouseMonitor.startMonitoring()
            mouseMonitor.onTrigger = { [weak self] trigger in
                let action = PreferencesManager.shared.action(for: trigger)
                self?.actionExecutor.execute(action)
            }
        } else {
            showPermissionsWindow()
        }
    }

    func showPermissionsWindow() {
        if permissionsWindowController == nil {
            let view = PermissionsView()
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                                  styleMask: [.titled, .closable],
                                  backing: .buffered,
                                  defer: false)
            window.center()
            window.title = "Permissions Required"
            window.contentView = NSHostingView(rootView: view)
            permissionsWindowController = NSWindowController(window: window)
        }
        permissionsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Monitor for when permission is granted to auto-close and start
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : false]
            if AXIsProcessTrustedWithOptions(options) {
                timer.invalidate()
                self?.permissionsWindowController?.close()
                self?.mouseMonitor.startMonitoring()
                self?.mouseMonitor.onTrigger = { trigger in
                    let action = PreferencesManager.shared.action(for: trigger)
                    ActionExecutor.shared.execute(action)
                }
            }
        }
    }

    func setupMenu() {
        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Super Corners", action: #selector(quitApp), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc func openSettings() {
        if settingsWindowController == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "Super Corners Settings"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
            window.titlebarAppearsTransparent = true
            window.setContentSize(NSSize(width: 800, height: 500))
            window.center()
            window.isReleasedWhenClosed = false

            settingsWindowController = NSWindowController(window: window)
        }

        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
