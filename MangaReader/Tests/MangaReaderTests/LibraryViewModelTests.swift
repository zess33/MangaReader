import XCTest
import SwiftData
@testable import MangaReaderCore

@MainActor
final class LibraryViewModelTests: XCTestCase {
    var viewModel: LibraryViewModel!
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        viewModel = LibraryViewModel()
        persistenceController = PersistenceController(inMemory: true)
    }

    func testLibraryFiltering() {
        let manga1 = Manga(id: "1", sourceID: "mock", title: "Solo Leveling", status: .completed, type: .manhwa)
        let manga2 = Manga(id: "2", sourceID: "mock", title: "One Piece", status: .ongoing, type: .manga)

        viewModel.libraryManga = [manga1, manga2]

        XCTAssertEqual(viewModel.filteredManga.count, 2)

        viewModel.selectedStatusFilter = .ongoing
        XCTAssertEqual(viewModel.filteredManga.count, 1)
        XCTAssertEqual(viewModel.filteredManga.first?.title, "One Piece")

        viewModel.selectedStatusFilter = nil
        viewModel.searchQuery = "Solo"
        XCTAssertEqual(viewModel.filteredManga.count, 1)
        XCTAssertEqual(viewModel.filteredManga.first?.title, "Solo Leveling")
    }
}
