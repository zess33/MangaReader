import Foundation
import SwiftData

/// Controlador central del contenedor SwiftData para iOS 17+.
@MainActor
public final class PersistenceController: Sendable {
    public static let shared = PersistenceController(inMemory: false)
    public static let preview = PersistenceController(inMemory: true)

    public let container: ModelContainer

    public init(inMemory: Bool = false) {
        let schema = Schema([
            SDManga.self,
            SDReadingProgress.self,
            SDHistoryItem.self,
            SDUserSettings.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLogger.persistence.info("ModelContainer de SwiftData inicializado correctamente (inMemory: \(inMemory))")
        } catch {
            AppLogger.persistence.fault("Error fatal al crear ModelContainer: \(error.localizedDescription)")
            fatalError("No se pudo crear el contenedor de persistencia SwiftData: \(error)")
        }
    }
}
