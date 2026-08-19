import SwiftUI
import SwiftData

/// Contenedor de navegacion principal con TabBar y NavigationStacks independientes.
public struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var homePath = NavigationPath()
    @State private var searchPath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    @State private var historyPath = NavigationPath()
    @State private var settingsPath = NavigationPath()

    public init() {}

    public var body: some View {
        TabView(selection: Binding(
            get: { appState.selectedTab },
            set: { appState.selectedTab = $0 }
        )) {
            // Tab 1: Inicio
            NavigationStack(path: $homePath) {
                HomeView(navigationPath: $homePath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route, path: $homePath)
                    }
            }
            .tabItem {
                Label(AppState.TabItem.home.title, systemImage: AppState.TabItem.home.iconName)
            }
            .tag(AppState.TabItem.home)

            // Tab 2: Buscar
            NavigationStack(path: $searchPath) {
                SearchView(navigationPath: $searchPath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route, path: $searchPath)
                    }
            }
            .tabItem {
                Label(AppState.TabItem.search.title, systemImage: AppState.TabItem.search.iconName)
            }
            .tag(AppState.TabItem.search)

            // Tab 3: Biblioteca
            NavigationStack(path: $libraryPath) {
                LibraryView(navigationPath: $libraryPath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route, path: $libraryPath)
                    }
            }
            .tabItem {
                Label(AppState.TabItem.library.title, systemImage: AppState.TabItem.library.iconName)
            }
            .tag(AppState.TabItem.library)

            // Tab 4: Historial
            NavigationStack(path: $historyPath) {
                HistoryView(navigationPath: $historyPath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route, path: $historyPath)
                    }
            }
            .tabItem {
                Label(AppState.TabItem.history.title, systemImage: AppState.TabItem.history.iconName)
            }
            .tag(AppState.TabItem.history)

            // Tab 5: Ajustes
            NavigationStack(path: $settingsPath) {
                SettingsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route, path: $settingsPath)
                    }
            }
            .tabItem {
                Label(AppState.TabItem.settings.title, systemImage: AppState.TabItem.settings.iconName)
            }
            .tag(AppState.TabItem.settings)
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute, path: Binding<NavigationPath>) -> some View {
        switch route {
        case .mangaDetail(let manga):
            MangaDetailView(manga: manga, navigationPath: path)
        case .reader(let manga, let chapter):
            ReaderView(manga: manga, chapter: chapter)
        case .sourceSettings:
            Text("Ajustes de Fuentes")
        case .readingSettings:
            Text("Ajustes de Lectura")
        }
    }
}
