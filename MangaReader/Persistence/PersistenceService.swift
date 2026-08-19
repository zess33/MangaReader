import Foundation
import SwiftData

/// Servicio centralizado de operaciones CRUD de persistencia con SwiftData.
@MainActor
public final class PersistenceService: Sendable {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Favoritos / Biblioteca
    public func isFavorite(mangaID: String) -> Bool {
        var descriptor = FetchDescriptor<SDManga>(predicate: #Predicate { $0.id == mangaID })
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor).first?.isFavorite) ?? false
    }

    public func toggleFavorite(manga: Manga) throws -> Bool {
        var descriptor = FetchDescriptor<SDManga>(predicate: #Predicate { $0.id == manga.id })
        descriptor.fetchLimit = 1
        
        if let existing = try context.fetch(descriptor).first {
            existing.isFavorite.toggle()
            if !existing.isFavorite && existing.addedToLibraryAt == nil {
                context.delete(existing)
            }
            try context.save()
            return existing.isFavorite
        } else {
            let newSDManga = SDManga(from: manga, isFavorite: true)
            context.insert(newSDManga)
            try context.save()
            return true
        }
    }

    public func fetchLibraryManga() throws -> [Manga] {
        let descriptor = FetchDescriptor<SDManga>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.addedToLibraryAt, order: .reverse)]
        )
        let results = try context.fetch(descriptor)
        return results.map { $0.toDomain() }
    }

    // MARK: - Progreso de lectura
    public func saveReadingProgress(
        manga: Manga,
        chapter: Chapter,
        pageIndex: Int,
        scrollPosition: Double = 0.0,
        isCompleted: Bool = false
    ) throws {
        var descriptor = FetchDescriptor<SDReadingProgress>(predicate: #Predicate { $0.mangaID == manga.id })
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.sourceID = manga.sourceID
            existing.mangaTitle = manga.title
            existing.coverURLString = manga.coverURL?.absoluteString
            existing.chapterID = chapter.id
            existing.chapterNumber = chapter.number
            existing.chapterTitle = chapter.title
            existing.pageIndex = pageIndex
            existing.scrollPosition = scrollPosition
            existing.lastReadAt = Date()
            existing.isCompleted = isCompleted
        } else {
            let progress = SDReadingProgress(
                mangaID: manga.id,
                sourceID: manga.sourceID,
                mangaTitle: manga.title,
                coverURLString: manga.coverURL?.absoluteString,
                chapterID: chapter.id,
                chapterNumber: chapter.number,
                chapterTitle: chapter.title,
                pageIndex: pageIndex,
                scrollPosition: scrollPosition,
                lastReadAt: Date(),
                isCompleted: isCompleted
            )
            context.insert(progress)
        }

        // Registrar en historial
        let historyItem = SDHistoryItem(
            mangaID: manga.id,
            sourceID: manga.sourceID,
            mangaTitle: manga.title,
            coverURLString: manga.coverURL?.absoluteString,
            chapterID: chapter.id,
            chapterNumber: chapter.number,
            chapterTitle: chapter.title,
            pageIndex: pageIndex,
            readAt: Date()
        )
        context.insert(historyItem)

        try context.save()
    }

    public func getReadingProgress(mangaID: String) -> ReadingProgress? {
        var descriptor = FetchDescriptor<SDReadingProgress>(predicate: #Predicate { $0.mangaID == mangaID })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first?.toDomain()
    }

    public func fetchRecentReadingProgress(limit: Int = 10) throws -> [SDReadingProgress] {
        var descriptor = FetchDescriptor<SDReadingProgress>(
            sortBy: [SortDescriptor(\.lastReadAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    // MARK: - Historial
    public func fetchHistory(limit: Int = 50) throws -> [SDHistoryItem] {
        var descriptor = FetchDescriptor<SDHistoryItem>(
            sortBy: [SortDescriptor(\.readAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    public func clearHistory() throws {
        try context.delete(model: SDHistoryItem.self)
        try context.save()
    }
}
