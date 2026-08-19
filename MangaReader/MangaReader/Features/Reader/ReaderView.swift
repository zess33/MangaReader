import SwiftUI
import SwiftData

/// Contenedor principal del Lector que conmuta entre modo Scroll Vertical y Pagina por Pagina.
public struct ReaderView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ReaderViewModel

    public init(manga: Manga, chapter: Chapter) {
        self._viewModel = State(initialValue: ReaderViewModel(manga: manga, chapter: chapter))
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch viewModel.pagesState {
            case .idle, .loading:
                ProgressView("Cargando páginas...")
                    .foregroundStyle(.white)
                    .tint(.white)
            case .loaded(let pages):
                if viewModel.readingDirection == .verticalWebtoon {
                    WebtoonVerticalReaderView(viewModel: viewModel, pages: pages)
                } else {
                    PagedMangaReaderView(viewModel: viewModel, pages: pages)
                }
            case .empty:
                ContentUnavailableView("Sin páginas disponibles", systemImage: "doc.text")
                    .foregroundStyle(.white)
            case .error(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                    Text("Error al cargar el capítulo")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Reintentar") {
                        Task { await viewModel.loadChapterPages(context: modelContext) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            // Controles superpuestos
            if viewModel.isControlsVisible {
                ReaderControlsOverlayView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .statusBarHidden(!viewModel.isControlsVisible)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.loadChapterPages(context: modelContext)
        }
        .onDisappear {
            viewModel.saveProgress(context: modelContext)
        }
    }
}
