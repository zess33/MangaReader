import Foundation

/// Fuente oficial de metadatos de AniList (GraphQL publica).
public final class AniListSource: MangaSource, @unchecked Sendable {
    public static let shared = AniListSource()

    public let id: String = "anilist"
    public let name: String = "AniList"
    public let baseURL: URL = URL(string: "https://graphql.anilist.co")!
    public let capabilities: SourceCapabilities = [.popular, .latest, .search, .filters]

    private let networkManager: NetworkManagerProtocol

    public init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    private let searchQuery = """
    query ($search: String, $page: Int, $perPage: Int) {
      Page (page: $page, perPage: $perPage) {
        media (search: $search, type: MANGA, sort: SEARCH_MATCH) {
          id
          title { romaji english native }
          description
          status
          format
          countryOfOrigin
          coverImage { extraLarge large }
          bannerImage
          genres
          averageScore
          chapters
        }
      }
    }
    """

    private let popularQuery = """
    query ($page: Int, $perPage: Int) {
      Page (page: $page, perPage: $perPage) {
        media (type: MANGA, sort: POPULARITY_DESC) {
          id
          title { romaji english native }
          description
          status
          format
          countryOfOrigin
          coverImage { extraLarge large }
          bannerImage
          genres
          averageScore
          chapters
        }
      }
    }
    """

    private let latestQuery = """
    query ($page: Int, $perPage: Int) {
      Page (page: $page, perPage: $perPage) {
        media (type: MANGA, sort: UPDATED_AT_DESC) {
          id
          title { romaji english native }
          description
          status
          format
          countryOfOrigin
          coverImage { extraLarge large }
          bannerImage
          genres
          averageScore
          chapters
        }
      }
    }
    """

    public func search(query: String, page: Int) async throws -> [Manga] {
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "",
            method: .post,
            headers: ["Content-Type": "application/json", "Accept": "application/json"],
            body: try JSONEncoder().encode(AniListGraphQLRequest(
                query: searchQuery,
                variables: [
                    "search": AnyCodable(query),
                    "page": AnyCodable(page),
                    "perPage": AnyCodable(20)
                ]
            ))
        )

        let response: AniListGraphQLResponse<AniListPageData> = try await networkManager.request(endpoint)
        guard let mediaList = response.data?.Page?.media else { return [] }
        return mediaList.map { AniListMapper.toDomain(dto: $0) }
    }

    public func getPopular(page: Int) async throws -> [Manga] {
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "",
            method: .post,
            headers: ["Content-Type": "application/json", "Accept": "application/json"],
            body: try JSONEncoder().encode(AniListGraphQLRequest(
                query: popularQuery,
                variables: ["page": AnyCodable(page), "perPage": AnyCodable(20)]
            ))
        )

        let response: AniListGraphQLResponse<AniListPageData> = try await networkManager.request(endpoint)
        guard let mediaList = response.data?.Page?.media else { return [] }
        return mediaList.map { AniListMapper.toDomain(dto: $0) }
    }

    public func getLatest(page: Int) async throws -> [Manga] {
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "",
            method: .post,
            headers: ["Content-Type": "application/json", "Accept": "application/json"],
            body: try JSONEncoder().encode(AniListGraphQLRequest(
                query: latestQuery,
                variables: ["page": AnyCodable(page), "perPage": AnyCodable(20)]
            ))
        )

        let response: AniListGraphQLResponse<AniListPageData> = try await networkManager.request(endpoint)
        guard let mediaList = response.data?.Page?.media else { return [] }
        return mediaList.map { AniListMapper.toDomain(dto: $0) }
    }

    public func getMangaDetails(id: String) async throws -> Manga {
        let cleanID = id.replacingOccurrences(of: "anilist-", with: "")
        guard let intID = Int(cleanID) else { throw SourceError.mangaNotFound(id: id) }

        let query = """
        query ($id: Int) {
          Media (id: $id, type: MANGA) {
            id
            title { romaji english native }
            description
            status
            format
            countryOfOrigin
            coverImage { extraLarge large }
            bannerImage
            genres
            averageScore
            chapters
          }
        }
        """

        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "",
            method: .post,
            headers: ["Content-Type": "application/json", "Accept": "application/json"],
            body: try JSONEncoder().encode(AniListGraphQLRequest(
                query: query,
                variables: ["id": AnyCodable(intID)]
            ))
        )

        let response: AniListGraphQLResponse<AniListSingleMediaData> = try await networkManager.request(endpoint)
        guard let media = response.data?.Media else { throw SourceError.mangaNotFound(id: id) }
        return AniListMapper.toDomain(dto: media)
    }

    public func getChapters(mangaID: String) async throws -> [Chapter] {
        // AniList es una base de datos de informacion/metadatos; delegamos capitulos a MangaDex o Mock
        return []
    }

    public func getChapterPages(chapterID: String) async throws -> [Page] {
        return []
    }
}
