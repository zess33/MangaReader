import XCTest
import UIKit
@testable import MangaReaderCore

final class ImageCacheTests: XCTestCase {
    var cache: ImageCache!

    override func setUp() {
        super.setUp()
        cache = ImageCache(name: "TestImageCache")
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }

    override func tearDown() {
        cache.clearMemoryCache()
        cache.clearDiskCache()
        super.tearDown()
    }

    func testInsertAndRetrieveImage() {
        let testURL = URL(string: "https://example.com/test_page_1.jpg")!
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 50, height: 50))
        }

        XCTAssertNil(cache.image(for: testURL))

        cache.insertImage(image, for: testURL)

        let retrieved = cache.image(for: testURL)
        XCTAssertNotNil(retrieved)

        // Limpiar solo RAM y verificar que se recupera del disco
        cache.clearMemoryCache()
        let diskRetrieved = cache.image(for: testURL)
        XCTAssertNotNil(diskRetrieved)
    }
}
