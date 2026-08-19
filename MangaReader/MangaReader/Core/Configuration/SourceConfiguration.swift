import Foundation

public struct SourceConfiguration: Sendable, Hashable {
    public let id: String
    public let displayName: String
    public let baseURL: URL
    public let timeout: TimeInterval
    public let customHeaders: [String: String]
    public let isReaderEnabled: Bool
    public let isMetadataOnly: Bool

    public init(
        id: String,
        displayName: String,
        baseURL: URL,
        timeout: TimeInterval = 20.0,
        customHeaders: [String: String] = [:],
        isReaderEnabled: Bool = true,
        isMetadataOnly: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.baseURL = baseURL
        self.timeout = timeout
        self.customHeaders = customHeaders
        self.isReaderEnabled = isReaderEnabled
        self.isMetadataOnly = isMetadataOnly
    }
}
