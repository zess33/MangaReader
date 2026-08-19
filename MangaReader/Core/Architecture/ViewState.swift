import Foundation

public enum ViewState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case empty(message: String)
    case error(Error)

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var data: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    public var errorMessage: String? {
        if case .error(let error) = self {
            return error.localizedDescription
        }
        return nil
    }
}
