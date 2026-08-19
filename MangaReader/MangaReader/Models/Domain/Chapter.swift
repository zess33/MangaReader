import Foundation

/// Representa un capitulo de un manga o manhwa.
public struct Chapter: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let mangaID: String
    public let sourceID: String
    public let title: String
    public let number: Double
    public let scanlationGroup: String?
    public let publishedAt: Date?
    public var isRead: Bool

    public init(
        id: String,
        mangaID: String,
        sourceID: String,
        title: String,
        number: Double,
        scanlationGroup: String? = nil,
        publishedAt: Date? = nil,
        isRead: Bool = false
    ) {
        self.id = id
        self.mangaID = mangaID
        self.sourceID = sourceID
        self.title = title
        self.number = number
        self.scanlationGroup = scanlationGroup
        self.publishedAt = publishedAt
        self.isRead = isRead
    }

    /// Formatea el numero de capitulo eliminando decimales innecesarios (e.g., "Capitulo 1" o "Capitulo 12.5").
    public var formattedChapterNumber: String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return "Capitulo \(Int(number))"
        } else {
            return "Capitulo \(number)"
        }
    }

    /// Titulo completo para mostrar en la interfaz del capitulo.
    public var fullDisplayTitle: String {
        let chapterPrefix = formattedChapterNumber
        if title.isEmpty || title == chapterPrefix {
            return chapterPrefix
        }
        return "\(chapterPrefix): \(title)"
    }

    /// Fecha formateada de publicacion.
    public var formattedPublishedDate: String? {
        guard let publishedAt = publishedAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: publishedAt)
    }
}
