import Foundation
import SwiftData

/// Entidad SwiftData para almacenar mangas en biblioteca y favoritos.
@Model
public final class SDManga {
    @Attribute(.unique) public var id: String
    public var sourceID: String
    public var title: String
    public var alternativeTitles: [String]
    public var coverURLString: String?
    public var bannerURLString: String?
    public var descriptionText: String
    public var author: String?
    public var artist: String?
    public var genres: [String]
    public var statusRawValue: String
    public var typeRawValue: String
    public var lastChapter: String?
    public var rating: Double?
    public var updatedAt: Date?
    public var isFavorite: Bool
    public var addedToLibraryAt: Date?
    public var preferredReadingDirectionRawValue: String?

    public init(
        id: String,
        sourceID: String,
        title: String,
        alternativeTitles: [String] = [],
        coverURLString: String? = nil,
        bannerURLString: String? = nil,
        descriptionText: String = "",
        author: String? = nil,
        artist: String? = nil,
        genres: [String] = [],
        statusRawValue: String = PublicationStatus.unknown.rawValue,
        typeRawValue: String = MangaType.manga.rawValue,
        lastChapter: String? = nil,
        rating: Double? = nil,
        updatedAt: Date? = nil,
        isFavorite: Bool = false,
        addedToLibraryAt: Date? = nil,
        preferredReadingDirectionRawValue: String? = nil
    ) {
        self.id = id
        self.sourceID = sourceID
        self.title = title
        self.alternativeTitles = alternativeTitles
        self.coverURLString = coverURLString
        self.bannerURLString = bannerURLString
        self.descriptionText = descriptionText
        self.author = author
        self.artist = artist
        self.genres = genres
        self.statusRawValue = statusRawValue
        self.typeRawValue = typeRawValue
        self.lastChapter = lastChapter
        self.rating = rating
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.addedToLibraryAt = addedToLibraryAt
        self.preferredReadingDirectionRawValue = preferredReadingDirectionRawValue
    }

    public convenience init(from manga: Manga, isFavorite: Bool = false) {
        self.init(
            id: manga.id,
            sourceID: manga.sourceID,
            title: manga.title,
            alternativeTitles: manga.alternativeTitles,
            coverURLString: manga.coverURL?.absoluteString,
            bannerURLString: manga.bannerURL?.absoluteString,
            descriptionText: manga.descriptionText,
            author: manga.author,
            artist: manga.artist,
            genres: manga.genres,
            statusRawValue: manga.status.rawValue,
            typeRawValue: manga.type.rawValue,
            lastChapter: manga.lastChapter,
            rating: manga.rating,
            updatedAt: manga.updatedAt,
            isFavorite: isFavorite || manga.isFavorite,
            addedToLibraryAt: Date(),
            preferredReadingDirectionRawValue: manga.preferredReadingDirection?.rawValue
        )
    }

    public func toDomain() -> Manga {
        Manga(
            id: id,
            sourceID: sourceID,
            title: title,
            alternativeTitles: alternativeTitles,
            coverURL: coverURLString.flatMap(URL.init(string:)),
            bannerURL: bannerURLString.flatMap(URL.init(string:)),
            descriptionText: descriptionText,
            author: author,
            artist: artist,
            genres: genres,
            status: PublicationStatus(rawValue: statusRawValue) ?? .unknown,
            type: MangaType(rawValue: typeRawValue) ?? .manga,
            lastChapter: lastChapter,
            rating: rating,
            updatedAt: updatedAt,
            isFavorite: isFavorite,
            preferredReadingDirection: preferredReadingDirectionRawValue.flatMap(ReadingDirection.init(rawValue:))
        )
    }
}
