import XCTest
import SwiftData
@testable import MangaReaderCore

@MainActor
final class HistoryViewModelTests: XCTestCase {
    var viewModel: HistoryViewModel!
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        viewModel = HistoryViewModel()
        persistenceController = PersistenceController(inMemory: true)
    }

    func testHistoryOperations() throws {
        let item = SDHistoryItem(
            mangaID: "test-manga",
            sourceID: "mock",
            mangaTitle: "Test Manga",
            chapterID: "ch-1",
            chapterNumber: 1.0,
            chapterTitle: "Episodio 1",
            pageIndex: 5
        )
        persistenceController.container.mainContext.insert(item)
        try persistenceController.container.mainContext.save()

        viewModel.loadHistory(context: persistenceController.container.mainContext)
        XCTAssertEqual(viewModel.historyItems.count, 1)
        XCTAssertEqual(viewModel.historyItems.first?.mangaTitle, "Test Manga")

        viewModel.clearAllHistory(context: persistenceController.container.mainContext)
        XCTAssertEqual(viewModel.historyItems.count, 0)
    }
}
