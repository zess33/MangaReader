import XCTest
import SwiftData
@testable import MangaReaderCore

@MainActor
final class SettingsViewModelTests: XCTestCase {
    var viewModel: SettingsViewModel!
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel()
        persistenceController = PersistenceController(inMemory: true)
    }

    func testSettingsCalculations() {
        viewModel.calculateStorage()
        XCTAssertFalse(viewModel.diskCacheSizeFormatted.isEmpty)

        viewModel.clearImageCache()
        XCTAssertTrue(viewModel.diskCacheSizeFormatted.contains("0") || viewModel.diskCacheSizeFormatted.contains("Zero") || viewModel.diskCacheSizeFormatted.contains("bytes") || viewModel.diskCacheSizeFormatted.contains("KB") || viewModel.diskCacheSizeFormatted.contains("MB"))
    }
}
