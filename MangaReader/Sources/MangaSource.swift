import Foundation

/// Protocolo fundamental que toda fuente de manga (Mock, AniList, MangaDex, etc.) debe implementar.
/// El lector y las vistas son completamente agnosticos a la implementacion interna de cada fuente.
public protocol MangaSource: Sendable {
    var id: String { get }
    var name: String { get }
    var configuration: SourceConfiguration { get }
    var isEnabled: Bool { get }
    var isMetadataOnly: Bool { get }

    /// Busca mangas/manhwas/webtoons segun una consulta de texto.
    func search(query: String) async throws -> [Manga]

    /// Obtiene el detalle completo de un manga por su ID especifico de la fuente.
    func getMangaDetails(id: String) async throws -> Manga

    /// Obtiene la lista de capitulos disponibles para un manga.
    func getChapters(mangaID: String) async throws -> [Chapter]

    /// Obtiene las paginas/imagenes de un capitulo para el lector.
    func getChapterPages(chapterID: String) async throws -> [Page]

    /// Obtiene mangas actualizados recientemente.
    func getLatest() async throws -> [Manga]

    /// Obtiene los mangas mas populares.
    func getPopular() async throws -> [Manga]
}
