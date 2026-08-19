import Foundation

/// Guarda y restaura con precision la posicion de lectura de un manga.
public struct ReadingProgress: Identifiable, Codable, Sendable, Hashable {
    public var id: String { mangaID }
    public let mangaID: String
    public var chapterID: String
    public var chapterNumber: Double
    public var pageIndex: Int
    public var scrollPosition: Double
    public var lastReadAt: Date
    public var isCompleted: Bool

    public init(
        mangaID: String,
        chapterID: String,
        chapterNumber: Double,
        pageIndex: Int = 0,
        scrollPosition: Double = 0.0,
        lastReadAt: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.mangaID = mangaID
        self.chapterID = chapterID
        self.chapterNumber = chapterNumber
        self.pageIndex = pageIndex
        self.scrollPosition = scrollPosition
        self.lastReadAt = lastReadAt
        self.isCompleted = isCompleted
    }

    /// Resumen legible del progreso de lectura actual.
    public var readableSummary: String {
        let chText = chapterNumber.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(chapterNumber))" : "\(chapterNumber)"
        return "Cap. \(chText) - Pag. \(pageIndex + 1)"
    }
}
