import SwiftUI
import SwiftData

/// Pantalla principal de Inicio con carruseles, continuar leyendo y populares.
public struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @Binding var navigationPath: NavigationPath

    public init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. Seccion Continuar Leyendo (si hay historial)
                if let latestProgress = viewModel.continueReadingList.first {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(title: "Continuar Leyendo")
                        
                        ContinueReadingCardView(progress: latestProgress) {
                            // Abrir manga para continuar
                            Task {
                                if let manga = try? await MockMangaSource.shared.getMangaDetails(id: latestProgress.mangaID) {
                                    navigationPath.append(AppRoute.mangaDetail(manga: manga))
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                // 2. Seccion Populares Destacados
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Populares 🔥", subtitle: "Las obras mas leidas")

                    switch viewModel.popularState {
                    case .idle, .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 180)
                    case .loaded(let mangas):
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(mangas) { manga in
                                    Button {
                                        navigationPath.append(AppRoute.mangaDetail(manga: manga))
                                    } label: {
                                        MangaCardView(manga: manga, width: 140, height: 200)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    case .empty:
                        ContentUnavailableView("Sin mangas populares", systemImage: "flame")
                    case .error(let error):
                        Text("Error al cargar populares: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }

                // 3. Seccion Actualizados Recientemente
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Recientes ⚡", subtitle: "Nuevos capitulos añadidos")

                    switch viewModel.latestState {
                    case .idle, .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 180)
                    case .loaded(let mangas):
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(mangas) { manga in
                                    Button {
                                        navigationPath.append(AppRoute.mangaDetail(manga: manga))
                                    } label: {
                                        MangaCardView(manga: manga, width: 130, height: 190)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    case .empty:
                        ContentUnavailableView("Sin actualizaciones", systemImage: "clock")
                    case .error:
                        EmptyView()
                    }
                }

                // 4. Seccion Tus Favoritos (si existen en SwiftData)
                if !viewModel.favoriteMangaList.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Tus Favoritos ❤️", subtitle: "En tu biblioteca")

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(viewModel.favoriteMangaList) { manga in
                                    Button {
                                        navigationPath.append(AppRoute.mangaDetail(manga: manga))
                                    } label: {
                                        MangaCardView(manga: manga, width: 130, height: 190)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Inicio")
        .refreshable {
            await viewModel.loadHomeContent(context: modelContext)
        }
        .task {
            await viewModel.loadHomeContent(context: modelContext)
        }
    }
}
