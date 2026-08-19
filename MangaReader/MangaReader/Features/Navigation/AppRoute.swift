import Foundation
import SwiftUI

/// Rutas de navegacion fuertemente tipadas para toda la aplicacion.
public enum AppRoute: Hashable, Sendable {
    case mangaDetail(manga: Manga)
    case reader(manga: Manga, chapter: Chapter)
    case sourceSettings
    case readingSettings
}
