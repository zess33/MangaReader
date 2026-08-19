import SwiftUI
import SwiftData

/// Lector continuo de Scroll Vertical para Manhwas y Webtoons.
public struct WebtoonVerticalReaderView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: ReaderViewModel
    public let pages: [Page]

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(pages) { page in
                        AsyncImage(url: page.imageURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.black.opacity(0.8))
                                    .aspectRatio(0.7, contentMode: .fit)
                                    .overlay {
                                        ProgressView()
                                            .tint(.white)
                                    }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Rectangle()
                                    .fill(Color.black.opacity(0.8))
                                    .aspectRatio(0.7, contentMode: .fit)
                                    .overlay {
                                        VStack(spacing: 8) {
                                            Image(systemName: "exclamationmark.triangle")
                                                .font(.title2)
                                                .foregroundStyle(.red)
                                            Text("Error al cargar página \(page.index + 1)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .id(page.index)
                        .onAppear {
                            viewModel.changePage(to: page.index, context: modelContext)
                        }
                    }

                    // Footer de fin de capitulo
                    VStack(spacing: 16) {
                        Text("Fin del \(viewModel.currentChapter.formattedChapterNumber)")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        if viewModel.hasNextChapter {
                            Button {
                                Task { await viewModel.goToNextChapter(context: modelContext) }
                            } label: {
                                HStack {
                                    Text("Siguiente Capítulo")
                                        .bold()
                                    Image(systemName: "arrow.down")
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .onAppear {
                if viewModel.currentPageIndex > 0 {
                    proxy.scrollTo(viewModel.currentPageIndex, anchor: .top)
                }
            }
        }
        .onTapGesture {
            viewModel.toggleControls()
        }
    }
}
