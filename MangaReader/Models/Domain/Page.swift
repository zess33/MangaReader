import Foundation

/// Representa una pagina individual dentro de un capitulo.
public struct Page: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let chapterID: String
    public let index: Int
    public let imageURL: URL
    public let headers: [String: String]?

    public init(
        id: String = UUID().uuidString,
        chapterID: String,
        index: Int,
        imageURL: URL,
        headers: [String: String]? = nil
    ) {
        self.id = id
        self.chapterID = chapterID
        self.index = index
        self.imageURL = imageURL
        self.headers = headers
    }

    public var displayPageNumber: String {
        "\(index + 1)"
    }
}
