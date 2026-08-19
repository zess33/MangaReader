import XCTest
@testable import MangaReaderCore

@MainActor
final class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel(source: MockMangaSource.shared)
    }

    func testSearchWithQuery() async throws {
        viewModel.searchText = "Solo Leveling"
        viewModel.performSearch()
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertNotNil(viewModel.state.data)
        XCTAssertEqual(viewModel.state.data?.first?.title, "Solo Leveling")
    }

    func testFilterByType() async throws {
        viewModel.selectType(.manhwa)
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertNotNil(viewModel.state.data)
        let allAreManhwa = viewModel.state.data?.allSatisfy { $0.type == .manhwa } ?? false
        XCTAssertTrue(allAreManhwa)
    }
}
