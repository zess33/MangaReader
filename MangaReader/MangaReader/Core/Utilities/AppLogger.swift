import Foundation
import OSLog

public enum AppLogger {
    private static let subsystem = "com.phuerta.MangaReader"

    public static let app = Logger(subsystem: subsystem, category: "App")
    public static let network = Logger(subsystem: subsystem, category: "Network")
    public static let sources = Logger(subsystem: subsystem, category: "Sources")
    public static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    public static let reader = Logger(subsystem: subsystem, category: "Reader")
    public static let cache = Logger(subsystem: subsystem, category: "Cache")
}
