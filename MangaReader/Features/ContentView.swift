import SwiftUI

/// Vista raiz de la aplicacion que aloja la navegacion principal.
public struct ContentView: View {
    public init() {}

    public var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .modelContainer(PersistenceController.preview.container)
}
