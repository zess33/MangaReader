import XCTest
import SwiftData
@testable import MangaReaderCore

@MainActor
final class MangaDetailViewModelTests: XCTestCase {
    var viewModel: MangaDetailViewModel!
    var persistenceController: PersistenceController!
    var manga: Manga!

    override func setUp() {
        super.setUp()
        manga = Manga(
            id: "mock-solo-leveling",
            sourceID: "mock",
            title: "Solo Leveling",
            status: .completed,
            type: .manhwa
        )
        viewModel = MangaDetailViewModel(manga: manga, source: MockMangaSource.shared)
        persistenceController = PersistenceController(inMemory: true)
    }

    func testLoadDataAndToggleFavorite() async throws {
        await viewModel.loadData(context: persistenceController.container.mainContext)

        XCTAssertNotNil(viewModel.chaptersState.data)
        XCTAssertGreaterThanOrEqual(viewModel.chaptersState.data?.count ?? 0, 5)

        XCTAssertFalse(viewModel.isFavorite)
        viewModel.toggleFavorite(context: persistenceController.container.mainContext)
        XCTAssertTrue(viewModel.isFavorite)
    }
}
