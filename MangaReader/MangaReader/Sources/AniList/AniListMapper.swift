import Foundation

/// Mapper que convierte DTOs de GraphQL de AniList a nuestros modelos canonicos Manga.
public enum AniListMapper {
    public static func toDomain(dto: AniListMediaDTO) -> Manga {
        let title = dto.title?.english ?? dto.title?.romaji ?? dto.title?.native ?? "Sin título"
        var altTitles: [String] = []
        if let romaji = dto.title?.romaji, romaji != title { altTitles.append(romaji) }
        if let native = dto.title?.native, native != title { altTitles.append(native) }

        let coverURLString = dto.coverImage?.extraLarge ?? dto.coverImage?.large ?? dto.coverImage?.medium
        let coverURL = coverURLString != nil ? URL(string: coverURLString!) : nil
        let bannerURL = dto.bannerImage != nil ? URL(string: dto.bannerImage!) : nil

        let status: PublicationStatus
        switch dto.status?.uppercased() {
        case "FINISHED": status = .completed
        case "RELEASING": status = .ongoing
        case "HIATUS": status = .hiatus
        case "CANCELLED": status = .cancelled
        default: status = .unknown
        }

        let type: MangaType
        if dto.countryOfOrigin == "KR" || dto.format == "MANHWA" {
            type = .manhwa
        } else if dto.countryOfOrigin == "CN" || dto.format == "MANHUA" {
            type = .manhua
        } else if dto.format == "NOVEL" {
            type = .novel
        } else {
            type = .manga
        }

        let rating: Double? = dto.averageScore != nil ? Double(dto.averageScore!) / 10.0 : nil

        // Limpiar tags HTML de la descripcion
        let cleanDescription = dto.description?
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<i>", with: "")
            .replacingOccurrences(of: "</i>", with: "")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "") ?? ""

        return Manga(
            id: "anilist-\(dto.id)",
            sourceID: "anilist",
            title: title,
            altTitles: altTitles,
            descriptionText: cleanDescription,
            coverURL: coverURL,
            bannerURL: bannerURL,
            status: status,
            type: type,
            genres: dto.genres ?? [],
            rating: rating,
            lastChapter: dto.chapters != nil ? "\(dto.chapters!)" : nil
        )
    }
}
