import Foundation

/// Estado de publicacion de una obra de manga / manhwa / webtoon.
public enum PublicationStatus: String, Codable, Sendable, CaseIterable, Identifiable {
    case ongoing = "ongoing"
    case completed = "completed"
    case hiatus = "hiatus"
    case cancelled = "cancelled"
    case unknown = "unknown"

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .ongoing: return "En emision"
        case .completed: return "Finalizado"
        case .hiatus: return "En pausa"
        case .cancelled: return "Cancelado"
        case .unknown: return "Desconocido"
        }
    }

    public var badgeColorName: String {
        switch self {
        case .ongoing: return "green"
        case .completed: return "blue"
        case .hiatus: return "orange"
        case .cancelled: return "red"
        case .unknown: return "gray"
        }
    }
}
