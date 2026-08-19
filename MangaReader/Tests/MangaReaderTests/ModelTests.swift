import XCTest
@testable import MangaReaderCore

final class ModelTests: XCTestCase {
    func testMangaCreationAndHelpers() {
        let manga = Manga(
            id: "solo-leveling-1",
            sourceID: "mock",
            title: "Solo Leveling",
            alternativeTitles: ["Na Honjaman Rebeleop"],
            coverURL: URL(string: "https://example.com/cover.jpg"),
            descriptionText: "Un cazador de rango E se convierte en el mas fuerte.",
            author: "Chugong",
            artist: "DUBU",
            genres: ["Accion", "Fantasia", "Sobrenatural"],
            status: .completed,
            type: .manhwa
        )

        XCTAssertEqual(manga.title, "Solo Leveling")
        XCTAssertEqual(manga.creatorsText, "Chugong (Guion), DUBU (Arte)")
        XCTAssertEqual(manga.genresJoined, "Accion - Fantasia - Sobrenatural")
        XCTAssertEqual(manga.status.localizedName, "Finalizado")
        XCTAssertEqual(manga.effectiveReadingDirection, .verticalWebtoon)
    }

    func testChapterFormatting() {
        let chapter1 = Chapter(
            id: "ch-1",
            mangaID: "solo-leveling-1",
            sourceID: "mock",
            title: "El despertar",
            number: 1.0
        )
        XCTAssertEqual(chapter1.formattedChapterNumber, "Capitulo 1")
        XCTAssertEqual(chapter1.fullDisplayTitle, "Capitulo 1: El despertar")

        let chapterHalf = Chapter(
            id: "ch-12.5",
            mangaID: "solo-leveling-1",
            sourceID: "mock",
            title: "Especial",
            number: 12.5
        )
        XCTAssertEqual(chapterHalf.formattedChapterNumber, "Capitulo 12.5")
        XCTAssertEqual(chapterHalf.fullDisplayTitle, "Capitulo 12.5: Especial")
    }

    func testReadingProgressSerialization() throws {
        let progress = ReadingProgress(
            mangaID: "manga-123",
            chapterID: "ch-42",
            chapterNumber: 42.0,
            pageIndex: 15,
            scrollPosition: 450.5
        )

        XCTAssertEqual(progress.readableSummary, "Cap. 42 - Pag. 16")

        let encoder = JSONEncoder()
        let data = try encoder.encode(progress)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ReadingProgress.self, from: data)

        XCTAssertEqual(decoded.mangaID, "manga-123")
        XCTAssertEqual(decoded.chapterID, "ch-42")
        XCTAssertEqual(decoded.pageIndex, 15)
        XCTAssertEqual(decoded.scrollPosition, 450.5)
    }
}
