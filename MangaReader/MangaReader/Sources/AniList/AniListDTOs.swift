import Foundation

public struct AniListGraphQLRequest: Encodable {
    public let query: String
    public let variables: [String: AnyCodable]

    public init(query: String, variables: [String: AnyCodable] = [:]) {
        self.query = query
        self.variables = variables
    }
}

public struct AnyCodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    public init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }

    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

public struct AniListGraphQLResponse<T: Decodable>: Decodable {
    public let data: T?
    public let errors: [AniListErrorDTO]?
}

public struct AniListErrorDTO: Decodable {
    public let message: String
}

public struct AniListPageData: Decodable {
    public let Page: AniListPageContent?
}

public struct AniListPageContent: Decodable {
    public let media: [AniListMediaDTO]?
}

public struct AniListSingleMediaData: Decodable {
    public let Media: AniListMediaDTO?
}

public struct AniListMediaDTO: Decodable {
    public let id: Int
    public let title: AniListTitleDTO?
    public let description: String?
    public let status: String?
    public let format: String?
    public let countryOfOrigin: String?
    public let coverImage: AniListCoverImageDTO?
    public let bannerImage: String?
    public let genres: [String]?
    public let averageScore: Int?
    public let chapters: Int?
}

public struct AniListTitleDTO: Decodable {
    public let romaji: String?
    public let english: String?
    public let native: String?
}

public struct AniListCoverImageDTO: Decodable {
    public let extraLarge: String?
    public let large: String?
    public let medium: String?
}
