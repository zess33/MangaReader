import Foundation

/// Fuente oficial de lectura de MangaDex (API REST v5 publica).
public final class MangaDexSource: MangaSource, @unchecked Sendable {
    public static let shared = MangaDexSource()

    public let id: String = "mangadex"
    public let name: String = "MangaDex"
    public let baseURL: URL = URL(string: "https://api.mangadex.org")!
    public let capabilities: SourceCapabilities = [.popular, .latest, .search, .chapters, .pages, .filters]

    private let networkManager: NetworkManagerProtocol

    public init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    public func search(query: String, page: Int) async throws -> [Manga] {
        let offset = (page - 1) * 20
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "manga",
            method: .get,
            queryParameters: [
                "title": query,
                "limit": "20",
                "offset": "\(offset)",
                "includes[]": "cover_art",
                "order[relevance]": "desc"
            ]
        )

        let response: MangaDexListResponse<MangaDexMangaDTO> = try await networkManager.request(endpoint)
        return response.data.map { MangaDexMapper.toDomain(dto: $0) }
    }

    public func getPopular(page: Int) async throws -> [Manga] {
        let offset = (page - 1) * 20
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "manga",
            method: .get,
            queryParameters: [
                "limit": "20",
                "offset": "\(offset)",
                "includes[]": "cover_art",
                "order[followedCount]": "desc"
            ]
        )

        let response: MangaDexListResponse<MangaDexMangaDTO> = try await networkManager.request(endpoint)
        return response.data.map { MangaDexMapper.toDomain(dto: $0) }
    }

    public func getLatest(page: Int) async throws -> [Manga] {
        let offset = (page - 1) * 20
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "manga",
            method: .get,
            queryParameters: [
                "limit": "20",
                "offset": "\(offset)",
                "includes[]": "cover_art",
                "order[latestUploadedChapter]": "desc"
            ]
        )

        let response: MangaDexListResponse<MangaDexMangaDTO> = try await networkManager.request(endpoint)
        return response.data.map { MangaDexMapper.toDomain(dto: $0) }
    }

    public func getMangaDetails(id: String) async throws -> Manga {
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "manga/\(id)",
            method: .get,
            queryParameters: [
                "includes[]": "cover_art"
            ]
        )

        let response: MangaDexEntityResponse<MangaDexMangaDTO> = try await networkManager.request(endpoint)
        return MangaDexMapper.toDomain(dto: response.data)
    }

    public func getChapters(mangaID: String) async throws -> [Chapter] {
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "manga/\(mangaID)/feed",
            method: .get,
            queryParameters: [
                "translatedLanguage[]": "es",
                "limit": "100",
                "order[chapter]": "desc"
            ]
        )

        let response: MangaDexListResponse<MangaDexChapterDTO> = try await networkManager.request(endpoint)
        return response.data.map { MangaDexMapper.toDomain(dto: $0, mangaID: mangaID) }
    }

    public func getChapterPages(chapterID: String) async throws -> [Page] {
        let endpoint = AnyEndpoint(
            baseURL: baseURL,
            path: "at-home/server/\(chapterID)",
            method: .get
        )

        let response: MangaDexAtHomeResponse = try await networkManager.request(endpoint)
        return MangaDexMapper.toPages(atHome: response, chapterID: chapterID)
    }
}
