import XCTest
@testable import MangaReaderCore

final class MangaDexMapperTests: XCTestCase {
    func testMapMangaDexMangaToDomain() {
        let dto = MangaDexMangaDTO(
            id: "32d76d19-8a05-4db0-9fc2-e0b0648fe9d0",
            type: "manga",
            attributes: MangaDexMangaAttributesDTO(
                title: ["en": "Solo Leveling"],
                altTitles: nil,
                description: ["es": "Hace 10 años, se abrieron puertas..."],
                status: "completed",
                originalLanguage: "ko",
                publicationDemographic: nil,
                lastChapter: "200",
                tags: nil
            ),
            relationships: nil
        )

        let domain = MangaDexMapper.toDomain(dto: dto)

        XCTAssertEqual(domain.id, "32d76d19-8a05-4db0-9fc2-e0b0648fe9d0")
        XCTAssertEqual(domain.title, "Solo Leveling")
        XCTAssertEqual(domain.status, .completed)
        XCTAssertEqual(domain.type, .manhwa)
        XCTAssertEqual(domain.lastChapter, "200")
    }
}
