import XCTest
@testable import MangaReaderCore

final class MockMangaSourceTests: XCTestCase {
    var source: MockMangaSource!

    override func setUp() {
        super.setUp()
        source = MockMangaSource()
    }

    func testSourceMetadata() {
        XCTAssertEqual(source.id, "mock")
        XCTAssertTrue(source.isEnabled)
        XCTAssertFalse(source.isMetadataOnly)
    }

    func testGetPopularAndLatest() async throws {
        let popular = try await source.getPopular()
        XCTAssertGreaterThanOrEqual(popular.count, 10)
        XCTAssertEqual(popular.first?.title, "Berserk")

        let latest = try await source.getLatest()
        XCTAssertGreaterThanOrEqual(latest.count, 10)
        XCTAssertEqual(latest.first?.title, "Solo Leveling")
    }

    func testSearchFunctionality() async throws {
        let soloResults = try await source.search(query: "Solo Leveling")
        XCTAssertEqual(soloResults.count, 1)
        XCTAssertEqual(soloResults.first?.title, "Solo Leveling")

        let shonenResults = try await source.search(query: "Shonen")
        XCTAssertGreaterThanOrEqual(shonenResults.count, 2)
    }

    func testGetDetailsAndChapters() async throws {
        let manga = try await source.getMangaDetails(id: "mock-solo-leveling")
        XCTAssertEqual(manga.title, "Solo Leveling")
        XCTAssertEqual(manga.effectiveReadingDirection, .verticalWebtoon)

        let chapters = try await source.getChapters(mangaID: manga.id)
        XCTAssertGreaterThanOrEqual(chapters.count, 5)

        let firstChapter = chapters.first!
        let pages = try await source.getChapterPages(chapterID: firstChapter.id)
        XCTAssertGreaterThanOrEqual(pages.count, 10)
        XCTAssertNotNil(pages.first?.imageURL)
    }
}
