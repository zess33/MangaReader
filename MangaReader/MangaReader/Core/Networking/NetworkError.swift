import Foundation

/// Errores tipados generados durante peticiones HTTP.
public enum NetworkError: LocalizedError, Equatable, Sendable {
    case invalidURL(String)
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(String)
    case encodingError(String)
    case noInternetConnection
    case timeout
    case rateLimited(retryAfter: TimeInterval?)
    case serverError(statusCode: Int, message: String?)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "URL invalida: \(url)"
        case .invalidResponse:
            return "Respuesta del servidor no valida o no reconocida."
        case .httpError(let code, _):
            return "Error HTTP (\(code))."
        case .decodingError(let msg):
            return "Error al procesar los datos: \(msg)"
        case .encodingError(let msg):
            return "Error al codificar la peticion: \(msg)"
        case .noInternetConnection:
            return "Sin conexion a Internet. Verifica tu red."
        case .timeout:
            return "La peticion ha superado el tiempo maximo de espera."
        case .rateLimited(let retry):
            if let retry = retry {
                return "Limite de peticiones alcanzado. Reintentar en \(Int(retry))s."
            }
            return "Limite de peticiones alcanzado. Espera un momento."
        case .serverError(let code, let msg):
            return "Error en el servidor (\(code)): \(msg ?? "Error interno")"
        case .unknown(let msg):
            return "Error desconocido: \(msg)"
        }
    }
}
