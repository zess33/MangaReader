import SwiftUI
import SwiftData

@main
struct MangaReaderApp: App {
    @State private var appState = AppState()
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(appState.appearanceMode.colorScheme)
        }
        .modelContainer(persistenceController.container)
    }
}
