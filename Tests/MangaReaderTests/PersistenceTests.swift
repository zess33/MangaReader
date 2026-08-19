import XCTest
import SwiftData
@testable import MangaReaderCore

@MainActor
final class PersistenceTests: XCTestCase {
    var controller: PersistenceController!
    var service: PersistenceService!

    override func setUp() async throws {
        controller = PersistenceController(inMemory: true)
        service = PersistenceService(context: controller.container.mainContext)
    }

    func testToggleFavoriteAndFetchLibrary() throws {
        let manga = Manga(
            id: "manga-test-1",
            sourceID: "mock",
            title: "Test Manga 1",
            status: .ongoing,
            type: .manga
        )

        XCTAssertFalse(service.isFavorite(mangaID: manga.id))

        let added = try service.toggleFavorite(manga: manga)
        XCTAssertTrue(added)
        XCTAssertTrue(service.isFavorite(mangaID: manga.id))

        let library = try service.fetchLibraryManga()
        XCTAssertEqual(library.count, 1)
        XCTAssertEqual(library.first?.title, "Test Manga 1")

        let removed = try service.toggleFavorite(manga: manga)
        XCTAssertFalse(removed)
        XCTAssertFalse(service.isFavorite(mangaID: manga.id))
    }

    func testSaveAndFetchReadingProgress() throws {
        let manga = Manga(
            id: "manga-test-2",
            sourceID: "mock",
            title: "Solo Leveling",
            status: .completed,
            type: .manhwa
        )

        let chapter = Chapter(
            id: "ch-10",
            mangaID: manga.id,
            sourceID: "mock",
            title: "Dungeon Boss",
            number: 10.0
        )

        try service.saveReadingProgress(
            manga: manga,
            chapter: chapter,
            pageIndex: 12,
            scrollPosition: 300.0,
            isCompleted: false
        )

        let progress = service.getReadingProgress(mangaID: manga.id)
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress?.chapterID, "ch-10")
        XCTAssertEqual(progress?.pageIndex, 12)
        XCTAssertEqual(progress?.scrollPosition, 300.0)

        let history = try service.fetchHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.mangaTitle, "Solo Leveling")
    }
}
