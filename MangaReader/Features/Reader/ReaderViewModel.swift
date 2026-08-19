import Foundation
import SwiftUI
import SwiftData
import Observation

/// ViewModel para el Lector Dual (Scroll Vertical y Pagina por Pagina) con Precarga Inteligente.
@MainActor
@Observable
public final class ReaderViewModel: BaseViewModel {
    public var manga: Manga
    public var currentChapter: Chapter
    public var allChapters: [Chapter] = []
    public var pagesState: ViewState<[Page]> = .idle

    public var currentPageIndex: Int = 0
    public var scrollPosition: Double = 0.0
    public var readingDirection: ReadingDirection
    public var isControlsVisible: Bool = true
    public var isChapterListPresented: Bool = false

    private let source: MangaSource

    public init(
        manga: Manga,
        chapter: Chapter,
        source: MangaSource = MockMangaSource.shared
    ) {
        self.manga = manga
        self.currentChapter = chapter
        self.source = source
        self.readingDirection = manga.effectiveReadingDirection
    }

    public func loadChapterPages(context: ModelContext) async {
        pagesState = .loading

        if allChapters.isEmpty {
            if let chapters = try? await source.getChapters(mangaID: manga.id) {
                self.allChapters = chapters.sorted { $0.number < $1.number }
            }
        }

        let persistenceService = PersistenceService(context: context)
        if let progress = persistenceService.getReadingProgress(mangaID: manga.id),
           progress.chapterID == currentChapter.id {
            self.currentPageIndex = progress.pageIndex
            self.scrollPosition = progress.scrollPosition
        } else {
            self.currentPageIndex = 0
            self.scrollPosition = 0.0
        }

        do {
            let pages = try await source.getChapterPages(chapterID: currentChapter.id)
            self.pagesState = .loaded(pages)
            
            saveProgress(context: context)
            triggerPrefetch()
        } catch {
            self.pagesState = .error(error)
            AppLogger.reader.error("Error al cargar paginas del capitulo \(self.currentChapter.id): \(error.localizedDescription)")
        }
    }

    public func toggleControls() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isControlsVisible.toggle()
        }
    }

    public func changePage(to newIndex: Int, context: ModelContext) {
        guard case .loaded(let pages) = pagesState, newIndex >= 0, newIndex < pages.count else { return }
        self.currentPageIndex = newIndex
        saveProgress(context: context)
        triggerPrefetch()
    }

    /// Precarga en paralelo las 3 paginas siguientes a la actual para lectura instantanea.
    private func triggerPrefetch() {
        guard case .loaded(let pages) = pagesState, !pages.isEmpty else { return }

        let nextIndices = (1...3).map { currentPageIndex + $0 }.filter { $0 < pages.count }
        let nextURLs = nextIndices.compactMap { pages[$0].imageURL }

        if !nextURLs.isEmpty {
            Task {
                await ImagePrefetcher.shared.prefetch(urls: nextURLs)
            }
        }
    }

    public func saveProgress(context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        guard case .loaded(let pages) = pagesState else { return }
        
        let isLastPage = !pages.isEmpty && currentPageIndex >= pages.count - 1
        try? persistenceService.saveReadingProgress(
            manga: manga,
            chapter: currentChapter,
            pageIndex: currentPageIndex,
            scrollPosition: scrollPosition,
            isCompleted: isLastPage
        )
    }

    public var currentChapterIndex: Int? {
        allChapters.firstIndex(where: { $0.id == currentChapter.id })
    }

    public var hasNextChapter: Bool {
        guard let idx = currentChapterIndex else { return false }
        return idx < allChapters.count - 1
    }

    public var hasPreviousChapter: Bool {
        guard let idx = currentChapterIndex else { return false }
        return idx > 0
    }

    public func goToNextChapter(context: ModelContext) async {
        guard let idx = currentChapterIndex, hasNextChapter else { return }
        let nextChapter = allChapters[idx + 1]
        self.currentChapter = nextChapter
        self.currentPageIndex = 0
        self.scrollPosition = 0.0
        await loadChapterPages(context: context)
    }

    public func goToPreviousChapter(context: ModelContext) async {
        guard let idx = currentChapterIndex, hasPreviousChapter else { return }
        let prevChapter = allChapters[idx - 1]
        self.currentChapter = prevChapter
        self.currentPageIndex = 0
        self.scrollPosition = 0.0
        await loadChapterPages(context: context)
    }

    public func selectChapter(_ chapter: Chapter, context: ModelContext) async {
        self.currentChapter = chapter
        self.currentPageIndex = 0
        self.scrollPosition = 0.0
        self.isChapterListPresented = false
        await loadChapterPages(context: context)
    }

    public func reset() {
        pagesState = .idle
    }
}
