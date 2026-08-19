import Foundation

/// Modelo interno unificado que representa un Manga, Manhwa o Webtoon.
/// Desacopla completamente a la aplicacion de cualquier fuente externa.
public struct Manga: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let sourceID: String
    public var title: String
    public var alternativeTitles: [String]
    public var coverURL: URL?
    public var bannerURL: URL?
    public var descriptionText: String
    public var author: String?
    public var artist: String?
    public var genres: [String]
    public var status: PublicationStatus
    public var type: MangaType
    public var lastChapter: String?
    public var rating: Double?
    public var updatedAt: Date?
    public var isFavorite: Bool
    public var preferredReadingDirection: ReadingDirection?

    public init(
        id: String,
        sourceID: String,
        title: String,
        alternativeTitles: [String] = [],
        coverURL: URL? = nil,
        bannerURL: URL? = nil,
        descriptionText: String = "",
        author: String? = nil,
        artist: String? = nil,
        genres: [String] = [],
        status: PublicationStatus = .unknown,
        type: MangaType = .manga,
        lastChapter: String? = nil,
        rating: Double? = nil,
        updatedAt: Date? = nil,
        isFavorite: Bool = false,
        preferredReadingDirection: ReadingDirection? = nil
    ) {
        self.id = id
        self.sourceID = sourceID
        self.title = title
        self.alternativeTitles = alternativeTitles
        self.coverURL = coverURL
        self.bannerURL = bannerURL
        self.descriptionText = descriptionText
        self.author = author
        self.artist = artist
        self.genres = genres
        self.status = status
        self.type = type
        self.lastChapter = lastChapter
        self.rating = rating
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.preferredReadingDirection = preferredReadingDirection
    }

    /// Autores y artistas combinados de forma limpia.
    public var creatorsText: String {
        let auth = author?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let art = artist?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !auth.isEmpty && !art.isEmpty && auth != art {
            return "\(auth) (Guion), \(art) (Arte)"
        } else if !auth.isEmpty {
            return auth
        } else if !art.isEmpty {
            return art
        }
        return "Autor desconocido"
    }

    /// Generos en formato de texto separado por comas o bullets.
    public var genresJoined: String {
        genres.isEmpty ? "General" : genres.joined(separator: " - ")
    }

    /// Direccion de lectura efectiva a utilizar.
    public var effectiveReadingDirection: ReadingDirection {
        preferredReadingDirection ?? type.defaultReadingDirection
    }
}
