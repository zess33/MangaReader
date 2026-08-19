import Foundation
import SwiftUI

/// Coordinador centralizado de todas las fuentes de manga (Mock, AniList, MangaDex).
@MainActor
@Observable
public final class SourceManager: @unchecked Sendable {
    public static let shared = SourceManager()

    public private(set) var availableSources: [MangaSource] = []
    public var activeSourceID: String = "mock" {
        didSet {
            UserDefaults.standard.set(activeSourceID, forKey: "kActiveSourceID")
        }
    }

    public init() {
        self.availableSources = [
            MockMangaSource.shared,
            AniListSource.shared,
            MangaDexSource.shared
        ]
        
        let savedID = UserDefaults.standard.string(forKey: "kActiveSourceID") ?? "mock"
        if availableSources.contains(where: { $0.id == savedID }) {
            self.activeSourceID = savedID
        } else {
            self.activeSourceID = "mock"
        }
    }

    public var activeSource: MangaSource {
        availableSources.first { $0.id == activeSourceID } ?? MockMangaSource.shared
    }

    public func getSource(by id: String) -> MangaSource {
        availableSources.first { $0.id == id } ?? activeSource
    }

    /// Busqueda concurrente agregada a traves de todas las fuentes registradas.
    public func searchAggregated(query: String) async -> [Manga] {
        await withTaskGroup(of: [Manga].self) { group in
            for source in availableSources {
                group.addTask {
                    do {
                        return try await source.search(query: query, page: 1)
                    } catch {
                        return []
                    }
                }
            }

            var aggregated: [Manga] = []
            var seenTitles: Set<String> = []

            for await results in group {
                for manga in results {
                    let normalized = manga.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    if !seenTitles.contains(normalized) {
                        seenTitles.insert(normalized)
                        aggregated.append(manga)
                    }
                }
            }

            return aggregated
        }
    }
}
