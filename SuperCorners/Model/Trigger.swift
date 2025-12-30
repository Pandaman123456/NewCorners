import Foundation

enum TriggerType: String, CaseIterable, Codable, Identifiable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case topEdge
    case bottomEdge
    case leftEdge
    case rightEdge

    var id: String { rawValue }

    var name: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        case .topEdge: return "Top Edge"
        case .bottomEdge: return "Bottom Edge"
        case .leftEdge: return "Left Edge"
        case .rightEdge: return "Right Edge"
        }
    }
}
