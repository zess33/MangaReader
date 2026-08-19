import XCTest
@testable import MangaReaderCore

@MainActor
final class SourceManagerTests: XCTestCase {
    var sourceManager: SourceManager!

    override func setUp() {
        super.setUp()
        sourceManager = SourceManager()
    }

    func testAvailableSourcesRegistration() {
        XCTAssertGreaterThanOrEqual(sourceManager.availableSources.count, 3)
        XCTAssertNotNil(sourceManager.getSource(by: "mock"))
        XCTAssertNotNil(sourceManager.getSource(by: "anilist"))
        XCTAssertNotNil(sourceManager.getSource(by: "mangadex"))
    }

    func testAggregatedSearch() async {
        let results = await sourceManager.searchAggregated(query: "Solo")
        XCTAssertFalse(results.isEmpty)
    }
}
