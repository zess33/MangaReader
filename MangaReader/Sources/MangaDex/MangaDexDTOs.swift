import Foundation

public struct MangaDexListResponse<T: Decodable>: Decodable {
    public let result: String
    public let response: String
    public let data: [T]
    public let limit: Int?
    public let offset: Int?
    public let total: Int?
}

public struct MangaDexEntityResponse<T: Decodable>: Decodable {
    public let result: String
    public let response: String
    public let data: T
}

public struct MangaDexMangaDTO: Decodable {
    public let id: String
    public let type: String
    public let attributes: MangaDexMangaAttributesDTO
    public let relationships: [MangaDexRelationshipDTO]?
}

public struct MangaDexMangaAttributesDTO: Decodable {
    public let title: [String: String]?
    public let altTitles: [[String: String]]?
    public let description: [String: String]?
    public let status: String?
    public let originalLanguage: String?
    public let publicationDemographic: String?
    public let lastChapter: String?
    public let tags: [MangaDexTagDTO]?
}

public struct MangaDexTagDTO: Decodable {
    public let id: String
    public let attributes: MangaDexTagAttributesDTO
}

public struct MangaDexTagAttributesDTO: Decodable {
    public let name: [String: String]?
}

public struct MangaDexRelationshipDTO: Decodable {
    public let id: String
    public let type: String
    public let attributes: [String: AnyDecodableValue]?
}

public struct AnyDecodableValue: Decodable {
    public let stringValue: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.stringValue = try? container.decode(String.self)
    }
}

public struct MangaDexChapterDTO: Decodable {
    public let id: String
    public let type: String
    public let attributes: MangaDexChapterAttributesDTO
}

public struct MangaDexChapterAttributesDTO: Decodable {
    public let title: String?
    public let volume: String?
    public let chapter: String?
    public let pages: Int?
    public let translatedLanguage: String?
    public let publishAt: String?
    public let readableAt: String?
}

public struct MangaDexAtHomeResponse: Decodable {
    public let result: String
    public let baseUrl: String
    public let chapter: MangaDexAtHomeChapterDTO
}

public struct MangaDexAtHomeChapterDTO: Decodable {
    public let hash: String
    public let data: [String]
    public let dataSaver: [String]
}
