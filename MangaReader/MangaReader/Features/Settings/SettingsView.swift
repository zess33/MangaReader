import SwiftUI
import SwiftData

/// Pantalla de Ajustes con seleccion de fuentes, configuracion del lector y gestion de almacenamiento.
public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var sourceManager = SourceManager.shared

    public init() {}

    public var body: some View {
        Form {
            // 1. Seccion de Fuentes
            Section(header: Text("Fuente Activa")) {
                Picker("Proveedor de Manga", selection: $sourceManager.activeSourceID) {
                    ForEach(sourceManager.availableSources, id: \.id) { source in
                        HStack {
                            Text(source.name)
                            if source.id == "mock" {
                                Text("(Sin conexión)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(source.id)
                    }
                }
                .pickerStyle(.menu)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Fuente actual: \(sourceManager.activeSource.name)")
                        .font(.footnote.bold())
                    Text("Capacidades: \(sourceManager.activeSource.capabilities.description)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            // 2. Seccion del Lector
            Section(header: Text("Lector de Manga y Webtoon")) {
                Picker("Modo Predeterminado", selection: $viewModel.selectedReadingDirection) {
                    ForEach(ReadingDirection.allCases) { direction in
                        Label(direction.displayName, systemImage: direction.iconName)
                            .tag(direction)
                    }
                }
            }

            // 3. Seccion de Almacenamiento y Cache
            Section(header: Text("Almacenamiento y Caché")) {
                HStack {
                    Text("Espacio en Caché")
                    Spacer()
                    Text(viewModel.diskCacheSizeFormatted)
                        .foregroundStyle(.secondary)
                }

                Button(role: .destructive) {
                    viewModel.isClearCacheAlertPresented = true
                } label: {
                    Label("Limpiar Caché de Imágenes", systemImage: "trash")
                        .foregroundStyle(.red)
                }

                Button(role: .destructive) {
                    viewModel.isResetProgressAlertPresented = true
                } label: {
                    Label("Restablecer Todo el Progreso", systemImage: "arrow.counterclockwise")
                        .foregroundStyle(.red)
                }
            }

            // 4. Seccion de Informacion
            Section(header: Text("Acerca de MangaReader")) {
                HStack {
                    Text("Versión")
                    Spacer()
                    Text("1.0.0 (Senior Native Build)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Dispositivo")
                    Spacer()
                    Text("Optimizado para iPhone (iOS 17+)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Desarrollador")
                    Spacer()
                    Text("Personal Edition")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Ajustes")
        .confirmationDialog("¿Limpiar toda la caché de imágenes?", isPresented: $viewModel.isClearCacheAlertPresented, titleVisibility: .visible) {
            Button("Limpiar Caché", role: .destructive) {
                viewModel.clearImageCache()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se liberará el espacio de almacenamiento ocupado por las imágenes descargadas.")
        }
        .confirmationDialog("¿Restablecer todo el progreso de lectura?", isPresented: $viewModel.isResetProgressAlertPresented, titleVisibility: .visible) {
            Button("Restablecer Todo", role: .destructive) {
                viewModel.resetAllProgress(context: modelContext)
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción borrará el historial y la posición guardada de todos tus mangas.")
        }
        .onAppear {
            viewModel.calculateStorage()
        }
    }
}
