import UIKit

/// Protocolo para el sistema de cache de imagenes en dos niveles (RAM + Disco).
public protocol ImageCacheProtocol: Sendable {
    func image(for url: URL) -> UIImage?
    func insertImage(_ image: UIImage, for url: URL, data: Data?)
    func removeImage(for url: URL)
    func clearMemoryCache()
    func clearDiskCache()
    func diskCacheSize() -> Int64
}
