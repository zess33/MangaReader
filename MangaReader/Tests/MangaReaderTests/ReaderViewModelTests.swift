import XCTest
import SwiftData
@testable import MangaReaderCore

@MainActor
final class ReaderViewModelTests: XCTestCase {
    var viewModel: ReaderViewModel!
    var persistenceController: PersistenceController!
    var manga: Manga!
    var chapter: Chapter!

    override func setUp() {
        super.setUp()
        manga = Manga(
            id: "mock-solo-leveling",
            sourceID: "mock",
            title: "Solo Leveling",
            status: .completed,
            type: .manhwa
        )
        chapter = Chapter(
            id: "mock-solo-leveling-ch-1",
            mangaID: manga.id,
            sourceID: "mock",
            title: "Episodio 1",
            number: 1.0
        )
        viewModel = ReaderViewModel(manga: manga, chapter: chapter, source: MockMangaSource.shared)
        persistenceController = PersistenceController(inMemory: true)
    }

    func testLoadChapterPagesAndSaveProgress() async throws {
        await viewModel.loadChapterPages(context: persistenceController.container.mainContext)

        XCTAssertNotNil(viewModel.pagesState.data)
        XCTAssertGreaterThanOrEqual(viewModel.pagesState.data?.count ?? 0, 10)

        // Cambiar de pagina y verificar progreso
        viewModel.changePage(to: 5, context: persistenceController.container.mainContext)
        XCTAssertEqual(viewModel.currentPageIndex, 5)

        let service = PersistenceService(context: persistenceController.container.mainContext)
        let savedProgress = service.getReadingProgress(mangaID: manga.id)
        XCTAssertNotNil(savedProgress)
        XCTAssertEqual(savedProgress?.pageIndex, 5)
        XCTAssertEqual(savedProgress?.chapterID, chapter.id)
    }
}
