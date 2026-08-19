import SwiftUI
import SwiftData

/// Controles flotantes superior e inferior del lector de manga.
public struct ReaderControlsOverlayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: ReaderViewModel

    public var body: some View {
        VStack {
            // Barra Superior
            HStack(spacing: 16) {
                Button {
                    viewModel.saveProgress(context: modelContext)
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .padding(8)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.manga.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(viewModel.currentChapter.fullDisplayTitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()

                // Menu selector de modo de lectura
                Menu {
                    ForEach(ReadingDirection.allCases) { direction in
                        Button {
                            viewModel.readingDirection = direction
                        } label: {
                            Label(
                                direction.displayName,
                                systemImage: viewModel.readingDirection == direction ? "checkmark" : direction.iconName
                            )
                        }
                    }
                } label: {
                    Image(systemName: viewModel.readingDirection.iconName)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(8)
                }

                // Selector de capitulos
                Button {
                    viewModel.isChapterListPresented = true
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.5))

            Spacer()

            // Barra Inferior (Scrubber de paginas y cambio de capitulo)
            if case .loaded(let pages) = viewModel.pagesState, !pages.isEmpty {
                VStack(spacing: 12) {
                    // Indicador de pagina / Slider
                    HStack(spacing: 12) {
                        Text("Pág. \(viewModel.currentPageIndex + 1)")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 60, alignment: .leading)

                        Slider(
                            value: Binding(
                                get: { Double(viewModel.currentPageIndex) },
                                set: { viewModel.changePage(to: Int($0), context: modelContext) }
                            ),
                            in: 0...Double(max(0, pages.count - 1)),
                            step: 1
                        )
                        .tint(Color.accentColor)

                        Text("\(pages.count)")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 40, alignment: .trailing)
                    }

                    // Botones de anterior y siguiente capitulo
                    HStack {
                        Button {
                            Task { await viewModel.goToPreviousChapter(context: modelContext) }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left.to.line")
                                Text("Cap. Anterior")
                                    .font(.caption.bold())
                            }
                            .foregroundStyle(viewModel.hasPreviousChapter ? .white : .white.opacity(0.3))
                        }
                        .disabled(!viewModel.hasPreviousChapter)

                        Spacer()

                        Button {
                            Task { await viewModel.goToNextChapter(context: modelContext) }
                        } label: {
                            HStack {
                                Text("Cap. Siguiente")
                                    .font(.caption.bold())
                                Image(systemName: "chevron.right.to.line")
                            }
                            .foregroundStyle(viewModel.hasNextChapter ? .white : .white.opacity(0.3))
                        }
                        .disabled(!viewModel.hasNextChapter)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $viewModel.isChapterListPresented) {
            NavigationStack {
                List(viewModel.allChapters) { chapter in
                    Button {
                        Task { await viewModel.selectChapter(chapter, context: modelContext) }
                    } label: {
                        HStack {
                            Text(chapter.fullDisplayTitle)
                                .font(.body.weight(chapter.id == viewModel.currentChapter.id ? .bold : .regular))
                                .foregroundStyle(chapter.id == viewModel.currentChapter.id ? Color.accentColor : .primary)
                            Spacer()
                            if chapter.id == viewModel.currentChapter.id {
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
                .navigationTitle("Capítulos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cerrar") {
                            viewModel.isChapterListPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
