import Foundation
import SwiftUI
import SwiftData

/// ViewModel de la pantalla de Inicio.
@MainActor
@Observable
public final class HomeViewModel: BaseViewModel {
    public var popularState: ViewState<[Manga]> = .idle
    public var latestState: ViewState<[Manga]> = .idle
    public var continueReadingList: [SDReadingProgress] = []
    public var favoriteMangaList: [Manga] = []

    private let source: MangaSource

    public init(source: MangaSource = MockMangaSource.shared) {
        self.source = source
    }

    public func loadHomeContent(context: ModelContext) async {
        popularState = .loading
        latestState = .loading

        loadLocalData(context: context)

        do {
            async let fetchedPopular = source.getPopular()
            async let fetchedLatest = source.getLatest()

            let (popular, latest) = try await (fetchedPopular, fetchedLatest)
            self.popularState = .loaded(popular)
            self.latestState = .loaded(latest)
        } catch {
            self.popularState = .error(error)
            self.latestState = .error(error)
            AppLogger.app.error("Error al cargar contenido de inicio: \(error.localizedDescription)")
        }
    }

    public func loadLocalData(context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        
        // Cargar progreso de lectura reciente
        if let recentProgress = try? persistenceService.fetchRecentReadingProgress(limit: 5) {
            self.continueReadingList = recentProgress
        }
        
        // Cargar favoritos
        if let favorites = try? persistenceService.fetchLibraryManga() {
            self.favoriteMangaList = favorites
        }
    }

    public func reset() {
        popularState = .idle
        latestState = .idle
        continueReadingList = []
        favoriteMangaList = []
    }
}
