import Foundation
import SwiftUI
import Observation

@Observable
public final class AppState: @unchecked Sendable {
    public var selectedTab: TabItem = .home
    public var appearanceMode: AppearanceMode = .system
    
    public enum TabItem: Int, CaseIterable, Identifiable {
        case home = 0
        case search = 1
        case library = 2
        case history = 3
        case settings = 4
        
        public var id: Int { rawValue }
        
        public var title: String {
            switch self {
            case .home: return "Inicio"
            case .search: return "Buscar"
            case .library: return "Biblioteca"
            case .history: return "Historial"
            case .settings: return "Ajustes"
            }
        }
        
        public var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .library: return "books.vertical.fill"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    public enum AppearanceMode: String, CaseIterable, Identifiable {
        case system = "Sistema"
        case light = "Claro"
        case dark = "Oscuro"
        
        public var id: String { rawValue }
        
        public var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    public init() {}
}
