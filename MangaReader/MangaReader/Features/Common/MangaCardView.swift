import SwiftUI

/// Tarjeta visual moderna para mostrar portadas de manga en cuadriculas o carruseles.
public struct MangaCardView: View {
    public let manga: Manga
    public let width: CGFloat
    public let height: CGFloat

    public init(manga: Manga, width: CGFloat = 130, height: CGFloat = 190) {
        self.manga = manga
        self.width = width
        self.height = height
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Portada con insignia de tipo y rating
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomLeading) {
                    if let coverURL = manga.coverURL {
                        AsyncImage(url: coverURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color(.tertiarySystemFill))
                                    .overlay {
                                        ProgressView()
                                    }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Rectangle()
                                    .fill(Color(.tertiarySystemFill))
                                    .overlay {
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                    }
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color(.tertiarySystemFill))
                            .overlay {
                                Image(systemName: "book.closed.fill")
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                
                // Insignia de tipo (Manga / Manhwa / Webtoon)
                Text(manga.type.displayName.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .padding(6)
            }

            // Titulo e informacion
            VStack(alignment: .leading, spacing: 3) {
                Text(manga.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 4) {
                    if let rating = manga.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let lastCh = manga.lastChapter {
                        Text("• Cap. \(lastCh)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: width, alignment: .leading)
        }
    }
}
