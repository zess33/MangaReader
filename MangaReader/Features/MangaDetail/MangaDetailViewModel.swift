import Foundation
import SwiftUI
import SwiftData
import Observation

/// ViewModel para la pantalla de detalle del manga.
@MainActor
@Observable
public final class MangaDetailViewModel: BaseViewModel {
    public var manga: Manga
    public var chaptersState: ViewState<[Chapter]> = .idle
    public var isFavorite: Bool = false
    public var readingProgress: ReadingProgress? = nil
    public var sortAscending: Bool = false
    public var isDescriptionExpanded: Bool = false

    private let source: MangaSource

    public init(manga: Manga, source: MangaSource = MockMangaSource.shared) {
        self.manga = manga
        self.source = source
        self.isFavorite = manga.isFavorite
    }

    public func loadData(context: ModelContext) async {
        let persistenceService = PersistenceService(context: context)
        self.isFavorite = persistenceService.isFavorite(mangaID: manga.id)
        self.readingProgress = persistenceService.getReadingProgress(mangaID: manga.id)

        chaptersState = .loading
        do {
            var fetched = try await source.getChapters(mangaID: manga.id)
            if sortAscending {
                fetched.sort { $0.number < $1.number }
            } else {
                fetched.sort { $0.number > $1.number }
            }
            self.chaptersState = .loaded(fetched)
        } catch {
            self.chaptersState = .error(error)
            AppLogger.app.error("Error al cargar capitulos: \(error.localizedDescription)")
        }
    }

    public func toggleFavorite(context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        if let newStatus = try? persistenceService.toggleFavorite(manga: manga) {
            self.isFavorite = newStatus
            self.manga.isFavorite = newStatus
        }
    }

    public func toggleSortOrder() {
        sortAscending.toggle()
        if case .loaded(var chapters) = chaptersState {
            if sortAscending {
                chapters.sort { $0.number < $1.number }
            } else {
                chapters.sort { $0.number > $1.number }
            }
            self.chaptersState = .loaded(chapters)
        }
    }

    public var targetResumeChapter: Chapter? {
        guard case .loaded(let chapters) = chaptersState else { return nil }
        if let progress = readingProgress {
            return chapters.first { $0.id == progress.chapterID } ?? chapters.last
        }
        // Si no hay progreso, el primer capitulo cronologico (numero mas bajo)
        return chapters.sorted { $0.number < $1.number }.first
    }

    public func reset() {
        chaptersState = .idle
    }
}
