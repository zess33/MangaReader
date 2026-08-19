import Foundation

public struct AppConfiguration {
    public static let appName = "MangaReader"
    public static let appVersion = "1.0.0"
    public static let minimumIOSVersion = "17.0"
    
    public static let defaultMaxCacheDiskSizeMB: Int = 1024
    public static let defaultMaxCacheMemorySizeMB: Int = 200
    public static let defaultPrefetchAheadCount: Int = 3
}
