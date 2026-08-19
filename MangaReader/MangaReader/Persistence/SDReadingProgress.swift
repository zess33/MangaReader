import Foundation
import SwiftData

/// Entidad SwiftData que almacena el progreso de lectura de cada manga.
@Model
public final class SDReadingProgress {
    @Attribute(.unique) public var mangaID: String
    public var sourceID: String
    public var mangaTitle: String
    public var coverURLString: String?
    public var chapterID: String
    public var chapterNumber: Double
    public var chapterTitle: String
    public var pageIndex: Int
    public var scrollPosition: Double
    public var lastReadAt: Date
    public var isCompleted: Bool

    public init(
        mangaID: String,
        sourceID: String = "",
        mangaTitle: String = "",
        coverURLString: String? = nil,
        chapterID: String,
        chapterNumber: Double,
        chapterTitle: String = "",
        pageIndex: Int = 0,
        scrollPosition: Double = 0.0,
        lastReadAt: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.mangaID = mangaID
        self.sourceID = sourceID
        self.mangaTitle = mangaTitle
        self.coverURLString = coverURLString
        self.chapterID = chapterID
        self.chapterNumber = chapterNumber
        self.chapterTitle = chapterTitle
        self.pageIndex = pageIndex
        self.scrollPosition = scrollPosition
        self.lastReadAt = lastReadAt
        self.isCompleted = isCompleted
    }

    public func toDomain() -> ReadingProgress {
        ReadingProgress(
            mangaID: mangaID,
            chapterID: chapterID,
            chapterNumber: chapterNumber,
            pageIndex: pageIndex,
            scrollPosition: scrollPosition,
            lastReadAt: lastReadAt,
            isCompleted: isCompleted
        )
    }
}
