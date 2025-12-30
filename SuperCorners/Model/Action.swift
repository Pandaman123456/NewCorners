import Foundation
import SwiftUI

struct Action: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: ActionCategory
    // We can't codable the closure, so we use an ID based lookup or a "Type" enum
    let type: ActionType

    // Some actions need parameters (e.g., custom script, custom hotkey)
    var parameters: [String: String] = [:]
}

enum ActionCategory: String, Codable, CaseIterable, Identifiable {
    case system = "System"
    case tools = "Tools"
    case app = "App Actions"
    case window = "Window Management"

    var id: String { rawValue }
}

enum ActionType: String, Codable {
    // System
    case screensaver
    case lockScreen
    case sleep
    case missionControl
    case appWindows
    case desktop
    case launchpad
    case volumeUp
    case volumeDown
    case mute
    case brightnessUp
    case brightnessDown

    // Tools
    case calculator
    case notes
    case colorPicker
    case ocr
    case dice
    case coinFlip
    case time

    // Apps
    case chatGPT
    case claude
    case perplexity

    // Generic
    case simulateHotkey
    case none
}
