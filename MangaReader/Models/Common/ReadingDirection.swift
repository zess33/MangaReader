import Foundation

/// Direccion y modalidad de lectura preferida para el lector de manga.
public enum ReadingDirection: String, Codable, Sendable, CaseIterable, Identifiable {
    /// Desplazamiento vertical continuo ideal para Manhwas y Webtoons.
    case verticalWebtoon = "verticalWebtoon"
    /// Pagina a pagina de derecha a izquierda (manga tradicional japones).
    case rightToLeft = "rightToLeft"
    /// Pagina a pagina de izquierda a derecha (estilo occidental / comic).
    case leftToRight = "leftToRight"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .verticalWebtoon: return "Scroll Vertical (Webtoon)"
        case .rightToLeft: return "Derecha a Izquierda (Manga)"
        case .leftToRight: return "Izquierda a Derecha (Occidental)"
        }
    }

    public var iconName: String {
        switch self {
        case .verticalWebtoon: return "arrow.up.and.down.text.horizontal"
        case .rightToLeft: return "arrow.left.to.line"
        case .leftToRight: return "arrow.right.to.line"
        }
    }
}
