import Foundation
import SwiftUI

/// ViewModel reactivo para la pantalla de busqueda con filtros en tiempo real.
@MainActor
@Observable
public final class SearchViewModel: BaseViewModel {
    public var searchText: String = ""
    public var selectedType: MangaType? = nil
    public var selectedGenre: String? = nil
    public var state: ViewState<[Manga]> = .idle

    public let availableGenres = [
        "Todos", "Accion", "Fantasia", "Shonen", "Seinen",
        "Manhwa", "Webtoon", "Aventura", "Comedia", "Sobrenatural", "Isekai"
    ]

    private let source: MangaSource
    private var searchTask: Task<Void, Never>?

    public init(source: MangaSource = MockMangaSource.shared) {
        self.source = source
    }

    public func performSearch() {
        searchTask?.cancel()
        searchTask = Task {
            // Debounce breve para no saturar al tipear
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled else { return }

            state = .loading
            do {
                var results: [Manga]
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    results = try await source.getPopular()
                } else {
                    results = try await source.search(query: searchText)
                }

                // Filtrar por tipo si esta seleccionado
                if let selectedType = selectedType {
                    results = results.filter { $0.type == selectedType }
                }

                // Filtrar por genero si esta seleccionado
                if let selectedGenre = selectedGenre, selectedGenre != "Todos" {
                    results = results.filter { manga in
                        manga.genres.contains { $0.localizedCaseInsensitiveContains(selectedGenre) }
                    }
                }

                if results.isEmpty {
                    self.state = .empty(message: "No se encontraron mangas que coincidan con la búsqueda.")
                } else {
                    self.state = .loaded(results)
                }
            } catch {
                if !Task.isCancelled {
                    self.state = .error(error)
                }
            }
        }
    }

    public func selectGenre(_ genre: String) {
        if selectedGenre == genre || genre == "Todos" {
            selectedGenre = nil
        } else {
            selectedGenre = genre
        }
        performSearch()
    }

    public func selectType(_ type: MangaType?) {
        if selectedType == type {
            selectedType = nil
        } else {
            selectedType = type
        }
        performSearch()
    }

    public func reset() {
        searchText = ""
        selectedType = nil
        selectedGenre = nil
        state = .idle
    }
}
