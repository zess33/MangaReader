import SwiftUI

/// Pantalla de busqueda con filtros de tipo, generos y cuadricula adaptativa de dos columnas.
public struct SearchView: View {
    @State private var viewModel = SearchViewModel()
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
            // Filtros de formato / tipo
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "Todos",
                        isSelected: viewModel.selectedType == nil && viewModel.selectedGenre == nil,
                        icon: "square.grid.2x2"
                    ) {
                        viewModel.selectedType = nil
                        viewModel.selectedGenre = nil
                        viewModel.performSearch()
                    }

                    ForEach(MangaType.allCases.filter { $0 != .unknown }) { type in
                        FilterChip(
                            title: type.displayName,
                            isSelected: viewModel.selectedType == type
                        ) {
                            viewModel.selectType(type)
                        }
                    }

                    ForEach(viewModel.availableGenres.filter { $0 != "Todos" }, id: \.self) { genre in
                        FilterChip(
                            title: genre,
                            isSelected: viewModel.selectedGenre == genre
                        ) {
                            viewModel.selectGenre(genre)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))

            Divider()

            // Resultados
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Buscando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded(let mangas):
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(mangas) { manga in
                                Button {
                                    navigationPath.append(AppRoute.mangaDetail(manga: manga))
                                } label: {
                                    MangaCardView(manga: manga, width: 160, height: 230)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                case .empty(let message):
                    ContentUnavailableView(
                        "Sin resultados",
                        systemImage: "magnifyingglass",
                        description: Text(message)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error(let error):
                    ContentUnavailableView(
                        "Error de búsqueda",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("Buscar")
        .searchable(text: $viewModel.searchText, prompt: "Buscar manga, manhwa, autor...")
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.performSearch()
        }
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.performSearch()
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption.weight(isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
