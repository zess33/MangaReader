import Foundation

public enum SourceError: LocalizedError, Equatable, Sendable {
    case sourceDisabled(sourceID: String)
    case unsupportedOperation(sourceName: String, operation: String)
    case mangaNotFound(id: String)
    case chapterNotFound(id: String)
    case emptyResults
    case networkFailure(underlying: String)
    case parsingFailure(underlying: String)
    case invalidPageURL(String)
    case rateLimited

    public var errorDescription: String? {
        switch self {
        case .sourceDisabled(let id):
            return "La fuente '\(id)' esta desactivada."
        case .unsupportedOperation(let name, let op):
            return "La operacion '\(op)' no esta soportada por \(name)."
        case .mangaNotFound(let id):
            return "No se encontro el manga: \(id)"
        case .chapterNotFound(let id):
            return "No se encontro el capitulo: \(id)"
        case .emptyResults:
            return "No se encontraron resultados."
        case .networkFailure(let msg):
            return "Error de red en la fuente: \(msg)"
        case .parsingFailure(let msg):
            return "Error de procesamiento en la fuente: \(msg)"
        case .invalidPageURL(let url):
            return "URL de pagina invalida: \(url)"
        case .rateLimited:
            return "Limite de solicitudes alcanzado en la fuente."
        }
    }
}
