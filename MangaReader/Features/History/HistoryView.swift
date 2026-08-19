import SwiftUI
import SwiftData

/// Pantalla de Historial con registro cronologico de capitulos leidos.
public struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HistoryViewModel()
    @Binding var navigationPath: NavigationPath

    public init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    public var body: some View {
        Group {
            if viewModel.historyItems.isEmpty {
                ContentUnavailableView(
                    "Sin Historial",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Los capítulos que leas aparecerán registrados aquí automáticamente.")
                )
            } else {
                List {
                    ForEach(viewModel.historyItems) { item in
                        Button {
                            // Abrir manga desde el historial
                            Task {
                                if let manga = try? await MockMangaSource.shared.getMangaDetails(id: item.mangaID) {
                                    navigationPath.append(AppRoute.mangaDetail(manga: manga))
                                }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                // Portada miniatura
                                if let urlString = item.coverURLString, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { img in
                                        img
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Rectangle().fill(Color(.tertiarySystemFill))
                                    }
                                    .frame(width: 50, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(width: 50, height: 70)
                                        .overlay {
                                            Image(systemName: "book.fill")
                                                .foregroundStyle(.secondary)
                                        }
                                }

                                // Detalle de la lectura
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.mangaTitle)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)

                                    Text(item.chapterTitle.isEmpty ? "Capítulo \(Int(item.chapterNumber))" : item.chapterTitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)

                                    HStack(spacing: 8) {
                                        Text("Página \(item.pageIndex + 1)")
                                            .font(.caption2.bold())
                                            .foregroundStyle(Color.accentColor)

                                        Text("• \(formattedDate(item.readAt))")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let item = viewModel.historyItems[index]
                            viewModel.deleteItem(item, context: modelContext)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Historial")
        .toolbar {
            if !viewModel.historyItems.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        viewModel.isClearAlertPresented = true
                    } label: {
                        Label("Vaciar", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .confirmationDialog(
            "¿Vaciar historial de lectura?",
            isPresented: $viewModel.isClearAlertPresented,
            titleVisibility: .visible
        ) {
            Button("Vaciar Todo", role: .destructive) {
                viewModel.clearAllHistory(context: modelContext)
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción eliminará el registro de lecturas pasadas.")
        }
        .onAppear {
            viewModel.loadHistory(context: modelContext)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
