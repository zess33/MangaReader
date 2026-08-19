import Foundation
import UIKit

/// Gestor de precarga anticipada de imagenes en segundo plano para el lector.
public actor ImagePrefetcher {
    public static let shared = ImagePrefetcher()

    private let cache: ImageCacheProtocol
    private let session: URLSession

    public init(cache: ImageCacheProtocol = ImageCache.shared) {
        self.cache = cache
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
    }

    /// Precarga un lote de URLs en segundo plano de manera concurrente.
    public func prefetch(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                // Si ya esta en cache, no descargar de nuevo
                if cache.image(for: url) != nil { continue }

                group.addTask(priority: .background) { [weak self] in
                    guard let self = self else { return }
                    await self.downloadAndCache(url: url)
                }
            }
        }
    }

    private func downloadAndCache(url: URL) async {
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode),
               let image = UIImage(data: data) {
                cache.insertImage(image, for: url, data: data)
                AppLogger.cache.debug("Precargada página exitosamente: \(url.lastPathComponent)")
            }
        } catch {
            // Falla silenciosa en precarga para no interrumpir al lector
        }
    }
}
