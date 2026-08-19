import Foundation
import SwiftData

/// Entidad SwiftData para almacenar el registro historico de capitulos leidos.
@Model
public final class SDHistoryItem {
    @Attribute(.unique) public var id: String
    public var mangaID: String
    public var sourceID: String
    public var mangaTitle: String
    public var coverURLString: String?
    public var chapterID: String
    public var chapterNumber: Double
    public var chapterTitle: String
    public var pageIndex: Int
    public var readAt: Date

    public init(
        id: String = UUID().uuidString,
        mangaID: String,
        sourceID: String,
        mangaTitle: String,
        coverURLString: String? = nil,
        chapterID: String,
        chapterNumber: Double,
        chapterTitle: String,
        pageIndex: Int = 0,
        readAt: Date = Date()
    ) {
        self.id = id
        self.mangaID = mangaID
        self.sourceID = sourceID
        self.mangaTitle = mangaTitle
        self.coverURLString = coverURLString
        self.chapterID = chapterID
        self.chapterNumber = chapterNumber
        self.chapterTitle = chapterTitle
        self.pageIndex = pageIndex
        self.readAt = readAt
    }
}
