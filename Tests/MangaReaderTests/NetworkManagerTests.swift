import XCTest
@testable import MangaReaderCore

final class NetworkManagerTests: XCTestCase {
    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
    }
    
    func testEndpointURLConstruction() throws {
        let endpoint = AnyEndpoint(
            baseURL: URL(string: "https://api.example.com")!,
            path: "search",
            queryParameters: ["q": "Solo Leveling"]
        )
        let request = try endpoint.makeURLRequest()
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertTrue(request.url?.absoluteString.contains("q=Solo%20Leveling") == true || request.url?.absoluteString.contains("q=Solo+Leveling") == true)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }
    
    func testViewStateTransitions() {
        var state: ViewState<String> = .idle
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.data)
        
        state = .loading
        XCTAssertTrue(state.isLoading)
        
        state = .loaded("Test Manga")
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.data, "Test Manga")
    }
}
