import XCTest
@testable import MangaReaderCore

final class AniListMapperTests: XCTestCase {
    func testMapAniListDTOToDomain() {
        let dto = AniListMediaDTO(
            id: 105398,
            title: AniListTitleDTO(romaji: "Solo Leveling", english: "Only I Level Up", native: "나 혼자만 레벨업"),
            description: "10 years ago, after the Gate opened...",
            status: "FINISHED",
            format: "MANHWA",
            countryOfOrigin: "KR",
            coverImage: AniListCoverImageDTO(extraLarge: "https://example.com/cover.jpg", large: nil, medium: nil),
            bannerImage: "https://example.com/banner.jpg",
            genres: ["Action", "Fantasy"],
            averageScore: 86,
            chapters: 200
        )

        let domain = AniListMapper.toDomain(dto: dto)

        XCTAssertEqual(domain.id, "anilist-105398")
        XCTAssertEqual(domain.title, "Only I Level Up")
        XCTAssertEqual(domain.status, .completed)
        XCTAssertEqual(domain.type, .manhwa)
        XCTAssertEqual(domain.rating, 8.6)
        XCTAssertEqual(domain.lastChapter, "200")
    }
}
