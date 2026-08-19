import SwiftUI

/// Tarjeta destacada "Continuar Leyendo" para la pantalla de inicio.
public struct ContinueReadingCardView: View {
    public let progress: SDReadingProgress
    public let action: () -> Void

    public init(progress: SDReadingProgress, action: @escaping () -> Void) {
        self.progress = progress
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Portada miniatura
                if let urlString = progress.coverURLString, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.tertiarySystemFill))
                    }
                    .frame(width: 70, height: 95)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 70, height: 95)
                        .overlay {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.secondary)
                        }
                }

                // Informacion y boton de reanudar
                VStack(alignment: .leading, spacing: 6) {
                    Text("CONTINUAR LEYENDO")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.accentColor)

                    Text(progress.mangaTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("Capítulo \(Int(progress.chapterNumber)) • Página \(progress.pageIndex + 1)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        Label("Reanudar", systemImage: "play.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.callout.bold())
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 8)
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}
