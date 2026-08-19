import Foundation

/// Tipo o formato de publicacion de la obra.
public enum MangaType: String, Codable, Sendable, CaseIterable, Identifiable {
    case manga = "manga"
    case manhwa = "manhwa"
    case manhua = "manhua"
    case webtoon = "webtoon"
    case novel = "novel"
    case unknown = "unknown"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .manga: return "Manga"
        case .manhwa: return "Manhwa"
        case .manhua: return "Manhua"
        case .webtoon: return "Webtoon"
        case .novel: return "Novela"
        case .unknown: return "General"
        }
    }

    /// Direccion de lectura recomendada por defecto para este tipo de obra.
    public var defaultReadingDirection: ReadingDirection {
        switch self {
        case .manhwa, .webtoon, .manhua:
            return .verticalWebtoon
        case .manga:
            return .rightToLeft
        case .novel, .unknown:
            return .leftToRight
        }
    }
}
