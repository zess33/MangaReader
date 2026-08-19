import XCTest
import SwiftData
@testable import MangaReaderCore

@MainActor
final class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        viewModel = HomeViewModel(source: MockMangaSource.shared)
        persistenceController = PersistenceController(inMemory: true)
    }

    func testLoadHomeContentSuccessfully() async {
        XCTAssertTrue(viewModel.popularState.isLoading == false)

        await viewModel.loadHomeContent(context: persistenceController.container.mainContext)

        XCTAssertNotNil(viewModel.popularState.data)
        XCTAssertGreaterThanOrEqual(viewModel.popularState.data?.count ?? 0, 5)

        XCTAssertNotNil(viewModel.latestState.data)
        XCTAssertGreaterThanOrEqual(viewModel.latestState.data?.count ?? 0, 5)
    }
}
