import Cocoa
import CoreGraphics

class MouseMonitor: ObservableObject {
    static let shared = MouseMonitor()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // Configurable parameters
    @Published var cornerSensitivity: CGFloat = 10.0 // pixels
    @Published var edgeSensitivity: CGFloat = 10.0 // pixels
    @Published var triggerDelay: TimeInterval = 0.15 // seconds

    // State
    private var lastTriggerTime: Date = Date.distantPast
    private var lastTriggeredType: TriggerType?
    private var debounceTimer: Timer?

    // Callback
    var onTrigger: ((TriggerType) -> Void)?

    init() {}

    func startMonitoring() {
        // We only need mouse moves.
        let mask = (1 << CGEventType.mouseMoved.rawValue) | (1 << CGEventType.leftMouseDragged.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(mask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                let monitor = Unmanaged<MouseMonitor>.fromOpaque(refcon!).takeUnretainedValue()
                monitor.handleMouseEvent(event: event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let eventTap = eventTap else {
            print("Failed to create event tap. Check accessibility permissions.")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        print("Mouse monitoring started.")
    }

    func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
        }
    }

    private func handleMouseEvent(event: CGEvent) {
        // Check ignored apps first
        if isAppIgnored() {
            return
        }

        let location = event.location
        checkTriggers(at: location)
    }

    private func isAppIgnored() -> Bool {
        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              let bundleID = frontApp.bundleIdentifier else {
            return false
        }
        return PreferencesManager.shared.ignoredApps.contains(bundleID)
    }

    private func checkTriggers(at location: CGPoint) {
        // Find which screen the mouse is on
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(location, $0.frame, false) }) else {
            return
        }

        // Convert CGEvent location (top-left origin) to Cocoa location (bottom-left origin)
        // using the Main Screen height as reference for global coordinates inversion.
        guard let mainScreenHeight = NSScreen.screens.first?.frame.height else { return }
        let cocoaPoint = NSPoint(x: location.x, y: mainScreenHeight - location.y)

        let screenFrame = screen.frame
        let minX = screenFrame.minX
        let maxX = screenFrame.maxX
        let minY = screenFrame.minY
        let maxY = screenFrame.maxY

        // Define active zones
        let cSense = cornerSensitivity
        let eSense = edgeSensitivity

        var activeTrigger: TriggerType?

        // Check Corners first
        // Top Left (Cocoa: maxY, minX)
        if cocoaPoint.x >= minX && cocoaPoint.x <= minX + cSense &&
           cocoaPoint.y <= maxY && cocoaPoint.y >= maxY - cSense {
            activeTrigger = .topLeft
        }
        // Top Right (Cocoa: maxY, maxX)
        else if cocoaPoint.x >= maxX - cSense && cocoaPoint.x <= maxX &&
                cocoaPoint.y <= maxY && cocoaPoint.y >= maxY - cSense {
            activeTrigger = .topRight
        }
        // Bottom Left (Cocoa: minY, minX)
        else if cocoaPoint.x >= minX && cocoaPoint.x <= minX + cSense &&
                cocoaPoint.y >= minY && cocoaPoint.y <= minY + cSense {
            activeTrigger = .bottomLeft
        }
        // Bottom Right (Cocoa: minY, maxX)
        else if cocoaPoint.x >= maxX - cSense && cocoaPoint.x <= maxX &&
                cocoaPoint.y >= minY && cocoaPoint.y <= minY + cSense {
            activeTrigger = .bottomRight
        }

        // Check Edges (if not a corner)
        // Top Edge
        else if cocoaPoint.y <= maxY && cocoaPoint.y >= maxY - eSense &&
                cocoaPoint.x > minX + cSense && cocoaPoint.x < maxX - cSense {
            activeTrigger = .topEdge
        }
        // Bottom Edge
        else if cocoaPoint.y >= minY && cocoaPoint.y <= minY + eSense &&
                cocoaPoint.x > minX + cSense && cocoaPoint.x < maxX - cSense {
            activeTrigger = .bottomEdge
        }
        // Left Edge
        else if cocoaPoint.x >= minX && cocoaPoint.x <= minX + eSense &&
                cocoaPoint.y > minY + cSense && cocoaPoint.y < maxY - cSense {
            activeTrigger = .leftEdge
        }
        // Right Edge
        else if cocoaPoint.x >= maxX - eSense && cocoaPoint.x <= maxX &&
                cocoaPoint.y > minY + cSense && cocoaPoint.y < maxY - cSense {
            activeTrigger = .rightEdge
        }

        if let trigger = activeTrigger {
            if trigger != lastTriggeredType {
                // New trigger entered
                scheduleTrigger(trigger)
            }
        } else {
            // Left all zones
            cancelTrigger()
        }
    }

    private func scheduleTrigger(_ trigger: TriggerType) {
        lastTriggeredType = trigger
        debounceTimer?.invalidate()

        if triggerDelay == 0 {
            executeTrigger(trigger)
        } else {
            debounceTimer = Timer.scheduledTimer(withTimeInterval: triggerDelay, repeats: false) { [weak self] _ in
                self?.executeTrigger(trigger)
            }
        }
    }

    private func cancelTrigger() {
        lastTriggeredType = nil
        debounceTimer?.invalidate()
        debounceTimer = nil
    }

    private func executeTrigger(_ trigger: TriggerType) {
        print("Trigger Activated: \(trigger.rawValue)")
        onTrigger?(trigger)
    }
}
