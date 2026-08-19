import Foundation
import SwiftUI
import SwiftData
import Observation

/// ViewModel de la pantalla de Ajustes para configuracion de fuentes, lector y almacenamiento.
@MainActor
@Observable
public final class SettingsViewModel: BaseViewModel {
    public var diskCacheSizeFormatted: String = "Calculando..."
    public var selectedReadingDirection: ReadingDirection = .verticalWebtoon {
        didSet {
            UserDefaults.standard.set(selectedReadingDirection.rawValue, forKey: "kDefaultReadingDirection")
        }
    }
    public var isClearCacheAlertPresented: Bool = false
    public var isResetProgressAlertPresented: Bool = false

    private let cache: ImageCacheProtocol

    public init(cache: ImageCacheProtocol = ImageCache.shared) {
        self.cache = cache
        if let savedDir = UserDefaults.standard.string(forKey: "kDefaultReadingDirection"),
           let dir = ReadingDirection(rawValue: savedDir) {
            self.selectedReadingDirection = dir
        }
    }

    public func calculateStorage() {
        let bytes = cache.diskCacheSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        self.diskCacheSizeFormatted = formatter.string(fromByteCount: bytes)
    }

    public func clearImageCache() {
        cache.clearMemoryCache()
        cache.clearDiskCache()
        calculateStorage()
    }

    public func resetAllProgress(context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        try? persistenceService.clearHistory()
        // Reset reading progress
        try? context.delete(model: SDReadingProgress.self)
        try? context.save()
    }

    public func reset() {
        calculateStorage()
    }
}
