import Foundation
import SwiftUI
import SwiftData

/// ViewModel para la gestion y visualizacion del historial cronologico de lectura.
@MainActor
@Observable
public final class HistoryViewModel: BaseViewModel {
    public var historyItems: [SDHistoryItem] = []
    public var isClearAlertPresented: Bool = false

    public init() {}

    public func loadHistory(context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        if let items = try? persistenceService.fetchHistory(limit: 50) {
            self.historyItems = items
        }
    }

    public func clearAllHistory(context: ModelContext) {
        let persistenceService = PersistenceService(context: context)
        try? persistenceService.clearHistory()
        loadHistory(context: context)
    }

    public func deleteItem(_ item: SDHistoryItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
        loadHistory(context: context)
    }

    public func reset() {
        historyItems = []
    }
}
