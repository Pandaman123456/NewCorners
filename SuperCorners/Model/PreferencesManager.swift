import Foundation
import SwiftUI

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    // Actions Assignment
    @AppStorage("trigger_topLeft") var topLeftAction: ActionType = .none
    @AppStorage("trigger_topRight") var topRightAction: ActionType = .none
    @AppStorage("trigger_bottomLeft") var bottomLeftAction: ActionType = .none
    @AppStorage("trigger_bottomRight") var bottomRightAction: ActionType = .none

    @AppStorage("trigger_topEdge") var topEdgeAction: ActionType = .none
    @AppStorage("trigger_bottomEdge") var bottomEdgeAction: ActionType = .none
    @AppStorage("trigger_leftEdge") var leftEdgeAction: ActionType = .none
    @AppStorage("trigger_rightEdge") var rightEdgeAction: ActionType = .none

    // Parameters (JSON String)
    @AppStorage("action_parameters") var actionParametersJSON: String = "{}"

    // Ignored Apps (JSON String of Bundle IDs)
    @AppStorage("ignored_apps") var ignoredAppsJSON: String = "[]"

    var ignoredApps: [String] {
        get {
            guard let data = ignoredAppsJSON.data(using: .utf8),
                  let list = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return list
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                ignoredAppsJSON = str
            }
        }
    }

    // Helpers for Parameters (like Hotkeys)
    // Key format: "TriggerID_ParamName" -> Value
    // We will use a dictionary for storage

    private var parameters: [String: String] {
        get {
            guard let data = actionParametersJSON.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                actionParametersJSON = str
            }
        }
    }

    func setParameter(_ value: String, key: String, for trigger: TriggerType) {
        var dict = parameters
        dict["\(trigger.id)_\(key)"] = value
        parameters = dict
    }

    func getParameter(key: String, for trigger: TriggerType) -> String? {
        return parameters["\(trigger.id)_\(key)"]
    }

    func action(for trigger: TriggerType) -> ActionType {
        switch trigger {
        case .topLeft: return topLeftAction
        case .topRight: return topRightAction
        case .bottomLeft: return bottomLeftAction
        case .bottomRight: return bottomRightAction
        case .topEdge: return topEdgeAction
        case .bottomEdge: return bottomEdgeAction
        case .leftEdge: return leftEdgeAction
        case .rightEdge: return rightEdgeAction
        }
    }

    func setAction(_ action: ActionType, for trigger: TriggerType) {
        switch trigger {
        case .topLeft: topLeftAction = action
        case .topRight: topRightAction = action
        case .bottomLeft: bottomLeftAction = action
        case .bottomRight: bottomRightAction = action
        case .topEdge: topEdgeAction = action
        case .bottomEdge: bottomEdgeAction = action
        case .leftEdge: leftEdgeAction = action
        case .rightEdge: rightEdgeAction = action
        }
    }
}
