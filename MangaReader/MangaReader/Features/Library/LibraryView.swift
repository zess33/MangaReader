import SwiftUI
import SwiftData

/// Pantalla de Biblioteca con mangas favoritos guardados localmente en SwiftData.
public struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LibraryViewModel()
    @Binding var navigationPath: NavigationPath

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Filtros por estado de publicacion
            if !viewModel.libraryManga.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        LibraryFilterChip(
                            title: "Todos (\(viewModel.libraryManga.count))",
                            isSelected: viewModel.selectedStatusFilter == nil
                        ) {
                            viewModel.selectedStatusFilter = nil
                        }

                        LibraryFilterChip(
                            title: "En emisión",
                            isSelected: viewModel.selectedStatusFilter == .ongoing
                        ) {
                            viewModel.selectedStatusFilter = (viewModel.selectedStatusFilter == .ongoing) ? nil : .ongoing
                        }

                        LibraryFilterChip(
                            title: "Finalizados",
                            isSelected: viewModel.selectedStatusFilter == .completed
                        ) {
                            viewModel.selectedStatusFilter = (viewModel.selectedStatusFilter == .completed) ? nil : .completed
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))

                Divider()
            }

            // Contenido de la Biblioteca
            Group {
                if viewModel.libraryManga.isEmpty {
                    ContentUnavailableView {
                        Label("Biblioteca Vacía", systemImage: "books.vertical")
                    } description: {
                        Text("Añade mangas a tus favoritos tocando el corazón en la pantalla de detalle.")
                    }
                } else if viewModel.filteredManga.isEmpty {
                    ContentUnavailableView(
                        "Sin coincidencias",
                        systemImage: "magnifyingglass",
                        description: Text("No hay mangas que coincidan con el filtro seleccionado.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.filteredManga) { manga in
                                Button {
                                    navigationPath.append(AppRoute.mangaDetail(manga: manga))
                                } label: {
                                    MangaCardView(manga: manga, width: 160, height: 230)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteManga(manga, context: modelContext)
                                    } label: {
                                        Label("Eliminar de Favoritos", systemImage: "heart.slash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Biblioteca")
        .searchable(text: $viewModel.searchQuery, prompt: "Buscar en tu biblioteca...")
        .onAppear {
            viewModel.loadLibrary(context: modelContext)
        }
    }
}

private struct LibraryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(isSelected ? .bold : .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
