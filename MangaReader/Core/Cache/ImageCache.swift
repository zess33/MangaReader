import UIKit
import CryptoKit

/// Gestor de cache de imagenes en dos niveles: Memoria RAM (NSCache) y Disco Local (FileManager).
public final class ImageCache: @unchecked Sendable, ImageCacheProtocol {
    public static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    private let lock = NSLock()

    // Limites configurables
    private let maxMemoryCost: Int = 200 * 1024 * 1024 // 200 MB
    private let maxDiskCost: Int64 = 1024 * 1024 * 1024 // 1 GB

    public init(name: String = "MangaReaderImageCache") {
        memoryCache.totalCostLimit = maxMemoryCost
        memoryCache.countLimit = 150

        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.diskCacheURL = cachesDirectory.appendingPathComponent(name, isDirectory: true)

        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    public func image(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)

        lock.lock()
        defer { lock.unlock() }

        // 1. Nivel 1: Memoria RAM
        if let memoryImage = memoryCache.object(forKey: key as NSString) {
            return memoryImage
        }

        // 2. Nivel 2: Disco Local
        let filePath = diskCacheURL.appendingPathComponent(key)
        if let data = try? Data(contentsOf: filePath),
           let diskImage = UIImage(data: data) {
            // Guardar de vuelta en RAM para accesos proximos rapidos
            let cost = data.count
            memoryCache.setObject(diskImage, forKey: key as NSString, cost: cost)
            return diskImage
        }

        return nil
    }

    public func insertImage(_ image: UIImage, for url: URL, data: Data? = nil) {
        let key = cacheKey(for: url)

        lock.lock()
        defer { lock.unlock() }

        let rawData = data ?? image.jpegData(compressionQuality: 0.85)
        let cost = rawData?.count ?? 0

        // Guardar en RAM
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)

        // Guardar en Disco
        if let rawData = rawData {
            let filePath = diskCacheURL.appendingPathComponent(key)
            try? rawData.write(to: filePath, options: .atomic)
        }
    }

    public func removeImage(for url: URL) {
        let key = cacheKey(for: url)
        lock.lock()
        defer { lock.unlock() }

        memoryCache.removeObject(forKey: key as NSString)
        let filePath = diskCacheURL.appendingPathComponent(key)
        try? fileManager.removeItem(at: filePath)
    }

    public func clearMemoryCache() {
        lock.lock()
        defer { lock.unlock() }
        memoryCache.removeAllObjects()
    }

    public func clearDiskCache() {
        lock.lock()
        defer { lock.unlock() }
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    public func diskCacheSize() -> Int64 {
        lock.lock()
        defer { lock.unlock() }

        guard let contents = try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        var totalSize: Int64 = 0
        for file in contents {
            if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
               let size = attributes[.size] as? Int64 {
                totalSize += size
            }
        }
        return totalSize
    }

    private func cacheKey(for url: URL) -> String {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
