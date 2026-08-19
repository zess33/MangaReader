import Foundation
import SwiftUI
import SwiftData
import Observation

/// ViewModel para la gestion y filtrado de la Biblioteca de mangas favoritos.
@MainActor
@Observable
public final class LibraryViewModel: BaseViewModel {
    public var libraryManga: [Manga] = []
    public var selectedStatusFilter: PublicationStatus? = nil
    public var searchQuery: String = ""

    public init() {}

    public func loadLibrary(context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        if let items = try? persistenceService.fetchLibraryManga() {
            self.libraryManga = items
        }
    }

    public var filteredManga: [Manga] {
        var result = libraryManga

        if let status = selectedStatusFilter {
            result = result.filter { $0.status == status }
        }

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { manga in
                manga.title.lowercased().contains(query) ||
                (manga.author?.lowercased().contains(query) ?? false) ||
                manga.genres.contains { $0.lowercased().contains(query) }
            }
        }

        return result
    }

    public func deleteManga(_ manga: Manga, context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        _ = try? persistenceService.toggleFavorite(manga: manga)
        loadLibrary(context: context)
    }

    public func reset() {
        libraryManga = []
        selectedStatusFilter = nil
        searchQuery = ""
    }
}
