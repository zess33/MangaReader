import SwiftUI
import SwiftData

/// Pantalla completa de detalle de un Manga / Manhwa / Webtoon.
public struct MangaDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MangaDetailViewModel
    @Binding var navigationPath: NavigationPath

    public init(manga: Manga, navigationPath: Binding<NavigationPath>) {
        self._viewModel = State(initialValue: MangaDetailViewModel(manga: manga))
        self._navigationPath = navigationPath
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Hero Header con fondo difuminado y portada
                ZStack(alignment: .bottom) {
                    if let banner = viewModel.manga.bannerURL ?? viewModel.manga.coverURL {
                        AsyncImage(url: banner) { img in
                            img
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color(.secondarySystemBackground)
                        }
                        .frame(height: 240)
                        .blur(radius: 20)
                        .overlay(Color.black.opacity(0.45))
                        .clipped()
                    }

                    // Informacion superpuesta
                    HStack(alignment: .bottom, spacing: 16) {
                        // Portada principal
                        if let coverURL = viewModel.manga.coverURL {
                            AsyncImage(url: coverURL) { img in
                                img
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color(.tertiarySystemFill))
                            }
                            .frame(width: 110, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.manga.title)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .lineLimit(2)

                            Text(viewModel.manga.creatorsText)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)

                            HStack(spacing: 6) {
                                // Badge de estado
                                Text(viewModel.manga.status.localizedName)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.blue.opacity(0.8))
                                    .clipShape(Capsule())

                                // Badge de tipo
                                Text(viewModel.manga.type.displayName)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.purple.opacity(0.8))
                                    .clipShape(Capsule())

                                if let rating = viewModel.manga.rating {
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", rating))
                                            .font(.caption2.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }

                // 2. Botones de Accion Principal (Leer / Favorito)
                HStack(spacing: 12) {
                    Button {
                        if let targetChapter = viewModel.targetResumeChapter {
                            navigationPath.append(AppRoute.reader(manga: viewModel.manga, chapter: targetChapter))
                        }
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                            Text(viewModel.readingProgress != nil ? "Continuar Lectura" : "Comenzar a Leer")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        viewModel.toggleFavorite(context: modelContext)
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(viewModel.isFavorite ? .red : .primary)
                            .frame(width: 50, height: 48)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                // 3. Generos
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.manga.genres, id: \.self) { genre in
                            Text(genre)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                }

                // 4. Sinopsis expandible
                if !viewModel.manga.descriptionText.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sinopsis")
                            .font(.headline)

                        Text(viewModel.manga.descriptionText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(viewModel.isDescriptionExpanded ? nil : 3)

                        Button(viewModel.isDescriptionExpanded ? "Leer menos" : "Leer más") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.isDescriptionExpanded.toggle()
                            }
                        }
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentColor)
                    }
                    .padding(.horizontal)
                }

                Divider()

                // 5. Lista de Capitulos
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if case .loaded(let chapters) = viewModel.chaptersState {
                            Text("Capítulos (\(chapters.count))")
                                .font(.headline)
                        } else {
                            Text("Capítulos")
                                .font(.headline)
                        }

                        Spacer()

                        Button {
                            viewModel.toggleSortOrder()
                        } label: {
                            Label(
                                viewModel.sortAscending ? "1 → N" : "N → 1",
                                systemImage: "arrow.up.arrow.down"
                            )
                            .font(.caption.bold())
                        }
                    }
                    .padding(.horizontal)

                    switch viewModel.chaptersState {
                    case .idle, .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 100)
                    case .loaded(let chapters):
                        LazyVStack(spacing: 4) {
                            ForEach(chapters) { chapter in
                                ChapterRowView(
                                    chapter: chapter,
                                    isCurrentProgress: viewModel.readingProgress?.chapterID == chapter.id
                                ) {
                                    navigationPath.append(AppRoute.reader(manga: viewModel.manga, chapter: chapter))
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    case .empty:
                        ContentUnavailableView("Sin capítulos", systemImage: "doc.text")
                    case .error(let error):
                        Text("Error al cargar capítulos: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadData(context: modelContext)
        }
    }
}
