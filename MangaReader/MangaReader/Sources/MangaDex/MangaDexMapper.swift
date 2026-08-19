import Foundation

/// Mapper que traduce respuestas REST v5 de MangaDex a nuestros modelos canonicos Manga, Chapter y Page.
public enum MangaDexMapper {
    public static func toDomain(dto: MangaDexMangaDTO) -> Manga {
        let title = dto.attributes.title?["en"] ??
                    dto.attributes.title?["ja-ro"] ??
                    dto.attributes.title?["es"] ??
                    dto.attributes.title?.values.first ?? "Sin título"

        var altTitles: [String] = []
        if let alts = dto.attributes.altTitles {
            for alt in alts {
                if let val = alt["en"] ?? alt["es"] ?? alt["ja-ro"] {
                    altTitles.append(val)
                }
            }
        }

        let desc = dto.attributes.description?["es"] ??
                   dto.attributes.description?["en"] ??
                   dto.attributes.description?.values.first ?? ""

        let status: PublicationStatus
        switch dto.attributes.status?.lowercased() {
        case "ongoing": status = .ongoing
        case "completed": status = .completed
        case "hiatus": status = .hiatus
        case "cancelled": status = .cancelled
        default: status = .unknown
        }

        let type: MangaType
        switch dto.attributes.originalLanguage?.lowercased() {
        case "ko": type = .manhwa
        case "zh", "zh-hk": type = .manhua
        default: type = .manga
        }

        var coverURL: URL? = nil
        if let coverRel = dto.relationships?.first(where: { $0.type == "cover_art" }),
           let fileName = coverRel.attributes?["fileName"]?.stringValue {
            coverURL = URL(string: "https://uploads.mangadex.org/covers/\(dto.id)/\(fileName).512.jpg")
        }

        let genres = dto.attributes.tags?.compactMap { $0.attributes.name?["en"] } ?? []

        return Manga(
            id: dto.id,
            sourceID: "mangadex",
            title: title,
            altTitles: altTitles,
            descriptionText: desc,
            coverURL: coverURL,
            status: status,
            type: type,
            genres: genres,
            lastChapter: dto.attributes.lastChapter
        )
    }

    public static func toDomain(dto: MangaDexChapterDTO, mangaID: String) -> Chapter {
        let chNumber = Double(dto.attributes.chapter ?? "0") ?? 0.0
        let chTitle = dto.attributes.title

        let dateFormatter = ISO8601DateFormatter()
        let pubDate = dto.attributes.publishAt != nil ? dateFormatter.date(from: dto.attributes.publishAt!) : nil

        return Chapter(
            id: dto.id,
            mangaID: mangaID,
            sourceID: "mangadex",
            title: chTitle,
            number: chNumber,
            language: dto.attributes.translatedLanguage ?? "es",
            publishedAt: pubDate,
            pageCount: dto.attributes.pages
        )
    }

    public static func toPages(atHome: MangaDexAtHomeResponse, chapterID: String) -> [Page] {
        let baseURL = atHome.baseUrl
        let hash = atHome.chapter.hash
        let files = atHome.chapter.data

        return files.enumerated().compactMap { index, file in
            guard let url = URL(string: "\(baseURL)/data/\(hash)/\(file)") else { return nil }
            return Page(
                id: "\(chapterID)-\(index)",
                chapterID: chapterID,
                index: index,
                imageURL: url
            )
        }
    }
}
