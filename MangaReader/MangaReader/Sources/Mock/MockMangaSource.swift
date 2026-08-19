import Foundation

/// Fuente de prueba local completa para probar la aplicacion sin requerir conexion a internet o APIs externas.
public final class MockMangaSource: MangaSource, @unchecked Sendable {
    public static let shared = MockMangaSource()

    public let id: String = "mock"
    public let name: String = "Fuente Mock (Local)"
    public let configuration: SourceConfiguration
    public var isEnabled: Bool = true
    public var isMetadataOnly: Bool = false

    private var mangas: [Manga] = []
    private var chaptersByMangaID: [String: [Chapter]] = [:]
    private var pagesByChapterID: [String: [Page]] = [:]

    public init() {
        self.configuration = SourceConfiguration(
            id: "mock",
            displayName: "Fuente Mock (Local)",
            baseURL: URL(string: "https://mock.mangareader.local")!,
            timeout: 5.0,
            isReaderEnabled: true,
            isMetadataOnly: false
        )
        setupMockData()
    }

    // MARK: - Protocol Methods
    public func search(query: String) async throws -> [Manga] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return mangas
        }
        return mangas.filter { manga in
            manga.title.lowercased().contains(trimmed) ||
            manga.alternativeTitles.contains { $0.lowercased().contains(trimmed) } ||
            (manga.author?.lowercased().contains(trimmed) ?? false) ||
            (manga.artist?.lowercased().contains(trimmed) ?? false) ||
            manga.genres.contains { $0.lowercased().contains(trimmed) }
        }
    }

    public func getMangaDetails(id: String) async throws -> Manga {
        guard let manga = mangas.first(where: { $0.id == id }) else {
            throw SourceError.mangaNotFound(id: id)
        }
        return manga
    }

    public func getChapters(mangaID: String) async throws -> [Chapter] {
        guard mangas.contains(where: { $0.id == mangaID }) else {
            throw SourceError.mangaNotFound(id: mangaID)
        }
        return chaptersByMangaID[mangaID] ?? []
    }

    public func getChapterPages(chapterID: String) async throws -> [Page] {
        if let pages = pagesByChapterID[chapterID] {
            return pages
        }
        
        var generatedPages: [Page] = []
        for i in 0..<12 {
            let page = Page(
                id: "\(chapterID)-page-\(i + 1)",
                chapterID: chapterID,
                index: i,
                imageURL: URL(string: "https://picsum.photos/800/1200?random=\(abs(chapterID.hashValue) + i)")!
            )
            generatedPages.append(page)
        }
        pagesByChapterID[chapterID] = generatedPages
        return generatedPages
    }

    public func getLatest() async throws -> [Manga] {
        mangas.sorted { ($0.updatedAt ?? Date.distantPast) > ($1.updatedAt ?? Date.distantPast) }
    }

    public func getPopular() async throws -> [Manga] {
        mangas.sorted { ($0.rating ?? 0.0) > ($1.rating ?? 0.0) }
    }

    // MARK: - Mock Data Setup
    private func setupMockData() {
        let now = Date()
        
        // 1. Solo Leveling
        let soloLeveling = Manga(
            id: "mock-solo-leveling",
            sourceID: id,
            title: "Solo Leveling",
            alternativeTitles: ["Na Honjaman Rebeleop", "I Alone Level-Up"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "Conocido como el cazador mas debil de toda la humanidad, Sung Jinwoo se encuentra atrapado en una misteriosa mazmorra doble. Al borde de la muerte, desbloquea una pantalla de misiones que solo el puede ver, otorgandole la capacidad unica de subir de nivel sin limites.",
            author: "Chugong",
            artist: "DUBU (REDICE STUDIO)",
            genres: ["Accion", "Fantasia", "Sobrenatural", "Superpoderes"],
            status: .completed,
            type: .manhwa,
            lastChapter: "200",
            rating: 9.8,
            updatedAt: now.addingTimeInterval(-3600 * 2),
            preferredReadingDirection: .verticalWebtoon
        )

        // 2. One Piece
        let onePiece = Manga(
            id: "mock-one-piece",
            sourceID: id,
            title: "One Piece",
            alternativeTitles: ["Wan Pisu"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1563089145-599997674d42?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "Monkey D. Luffy se niega a que nadie se interponga en su camino para convertirse en el Rey de los Piratas. Zarpa en busca del legendario tesoro de Gol D. Roger, el One Piece.",
            author: "Eiichiro Oda",
            artist: "Eiichiro Oda",
            genres: ["Shonen", "Aventura", "Comedia", "Fantasia"],
            status: .ongoing,
            type: .manga,
            lastChapter: "1115",
            rating: 9.7,
            updatedAt: now.addingTimeInterval(-3600 * 5),
            preferredReadingDirection: .rightToLeft
        )

        // 3. Tower of God
        let towerOfGod = Manga(
            id: "mock-tower-of-god",
            sourceID: id,
            title: "Tower of God",
            alternativeTitles: ["Sin-ui Tap", "La Torre de Dios"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "Que deseas? Dinero y riquezas? Honor y orgullo? Autoridad y poder? Venganza? O algo que trascienda todo lo demas? Lo que sea que desees, esta aqui arriba en la Torre.",
            author: "SIU",
            artist: "SIU",
            genres: ["Fantasia", "Accion", "Misterio", "Drama"],
            status: .ongoing,
            type: .webtoon,
            lastChapter: "600",
            rating: 9.4,
            updatedAt: now.addingTimeInterval(-3600 * 12),
            preferredReadingDirection: .verticalWebtoon
        )

        // 4. Berserk
        let berserk = Manga(
            id: "mock-berserk",
            sourceID: id,
            title: "Berserk",
            alternativeTitles: ["Beruseruku"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1514533450685-4493e01d1fdc?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "Guts, un guerrero marcado por un destino tragico, empuñando una espada descomunal en una sangrienta cruzada contra los apostoles y la Mano de Dios.",
            author: "Kentaro Miura",
            artist: "Studio Gaga",
            genres: ["Seinen", "Fantasia Oscura", "Accion", "Psicologico"],
            status: .ongoing,
            type: .manga,
            lastChapter: "376",
            rating: 9.9,
            updatedAt: now.addingTimeInterval(-3600 * 48),
            preferredReadingDirection: .rightToLeft
        )

        // 5. Jujutsu Kaisen
        let jjk = Manga(
            id: "mock-jujutsu-kaisen",
            sourceID: id,
            title: "Jujutsu Kaisen",
            alternativeTitles: ["Guerra de Hechiceros"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1563089145-599997674d42?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "Yuji Itadori se traga un dedo maldito para salvar a un amigo, convirtiendose en el anfitrion de Ryomen Sukuna, el temible Rey de las Maldiciones.",
            author: "Gege Akutami",
            artist: "Gege Akutami",
            genres: ["Shonen", "Sobrenatural", "Accion", "Demonios"],
            status: .completed,
            type: .manga,
            lastChapter: "271",
            rating: 9.3,
            updatedAt: now.addingTimeInterval(-3600 * 24),
            preferredReadingDirection: .rightToLeft
        )

        // 6. Spy x Family
        let spyFamily = Manga(
            id: "mock-spy-family",
            sourceID: id,
            title: "Spy x Family",
            alternativeTitles: ["Espia x Familia"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "El maestro espia Twilight debe formar una familia ficticia para una mision de alto riesgo. Sin saberlo, adopta a una niña con telepatia y se casa con una asesina a sueldo.",
            author: "Tatsuya Endo",
            artist: "Tatsuya Endo",
            genres: ["Comedia", "Accion", "Recuentos de la vida", "Espias"],
            status: .ongoing,
            type: .manga,
            lastChapter: "98",
            rating: 9.2,
            updatedAt: now.addingTimeInterval(-3600 * 72),
            preferredReadingDirection: .rightToLeft
        )

        // 7. Omniscient Reader's Viewpoint
        let orv = Manga(
            id: "mock-orv",
            sourceID: id,
            title: "Omniscient Reader's Viewpoint",
            alternativeTitles: ["Punto de vista del Lector Omnisciente", "Jeonjijeok Dokja Sijeom"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "Dokja era el unico lector de una novela web olvidada. Cuando el mundo de la novela se convierte en realidad, el es el unico que sabe como termina la historia.",
            author: "sing N song",
            artist: "Sleepy-C",
            genres: ["Manhwa", "Accion", "Fantasia", "Apocaliptico"],
            status: .ongoing,
            type: .manhwa,
            lastChapter: "215",
            rating: 9.6,
            updatedAt: now.addingTimeInterval(-3600 * 4),
            preferredReadingDirection: .verticalWebtoon
        )

        // 8. Chainsaw Man
        let chainsawMan = Manga(
            id: "mock-chainsaw-man",
            sourceID: id,
            title: "Chainsaw Man",
            alternativeTitles: ["El Hombre Motosierra"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "Denji es un joven que vive endeudado hasta que se fusiona con su perro demonio Pochita, renaciendo como el implacable demonio motosierra.",
            author: "Tatsuki Fujimoto",
            artist: "Tatsuki Fujimoto",
            genres: ["Shonen", "Accion", "Terror", "Comedia Oscura"],
            status: .ongoing,
            type: .manga,
            lastChapter: "168",
            rating: 9.1,
            updatedAt: now.addingTimeInterval(-3600 * 18),
            preferredReadingDirection: .rightToLeft
        )

        // 9. The Beginning After the End
        let tbate = Manga(
            id: "mock-tbate",
            sourceID: id,
            title: "The Beginning After the End",
            alternativeTitles: ["TBATE", "El comienzo despues del fin"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1563089145-599997674d42?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "El Rey Grey renace en un mundo de magia y monstruos como Arthur Leywin. Con los recuerdos de su vida pasada, se entrena para convertirse en un mago prodigio.",
            author: "TurtleMe",
            artist: "Fuyuki23",
            genres: ["Manhwa", "Isekai", "Magia", "Aventura", "Accion"],
            status: .ongoing,
            type: .manhwa,
            lastChapter: "185",
            rating: 9.5,
            updatedAt: now.addingTimeInterval(-3600 * 10),
            preferredReadingDirection: .verticalWebtoon
        )

        // 10. Frieren: Beyond Journey's End
        let frieren = Manga(
            id: "mock-frieren",
            sourceID: id,
            title: "Frieren: Beyond Journey's End",
            alternativeTitles: ["Sousou no Frieren"],
            coverURL: URL(string: "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=600&auto=format&fit=crop&q=80"),
            bannerURL: URL(string: "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1200&auto=format&fit=crop&q=80"),
            descriptionText: "La maga elfa Frieren y sus compañeros derrotaron al Rey Demonio tras 10 años. Decadas despues, emprende un viaje para comprender el valor del tiempo y los sentimientos humanos.",
            author: "Kanehito Yamada",
            artist: "Tsukasa Abe",
            genres: ["Fantasia", "Aventura", "Drama", "Recuentos de la vida"],
            status: .ongoing,
            type: .manga,
            lastChapter: "130",
            rating: 9.6,
            updatedAt: now.addingTimeInterval(-3600 * 8),
            preferredReadingDirection: .rightToLeft
        )

        self.mangas = [
            soloLeveling,
            onePiece,
            towerOfGod,
            berserk,
            jjk,
            spyFamily,
            orv,
            chainsawMan,
            tbate,
            frieren
        ]

        // Generar capitulos para cada manga
        for manga in mangas {
            var chapters: [Chapter] = []
            let count = 8
            for c in 1...count {
                let chID = "\(manga.id)-ch-\(c)"
                let chapter = Chapter(
                    id: chID,
                    mangaID: manga.id,
                    sourceID: id,
                    title: "\(manga.title) - Episodio \(c)",
                    number: Double(c),
                    scanlationGroup: "Scanlation Oficial",
                    publishedAt: now.addingTimeInterval(-Double((count - c) * 86400 * 3)),
                    isRead: c == 1
                )
                chapters.append(chapter)

                // Generar paginas para el capitulo
                var pages: [Page] = []
                let pageCount = (manga.effectiveReadingDirection == .verticalWebtoon) ? 15 : 18
                for p in 0..<pageCount {
                    let page = Page(
                        id: "\(chID)-p-\(p + 1)",
                        chapterID: chID,
                        index: p,
                        imageURL: URL(string: "https://picsum.photos/900/1300?random=\(abs(chID.hashValue) + p)")!
                    )
                    pages.append(page)
                }
                pagesByChapterID[chID] = pages
            }
            // Capitulos ordenados de mayor a menor
            chaptersByMangaID[manga.id] = chapters.reversed()
        }
    }
}
