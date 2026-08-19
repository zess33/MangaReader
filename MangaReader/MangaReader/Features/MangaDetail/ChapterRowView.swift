import SwiftUI

/// Fila individual de capitulo en la pantalla de detalle con estado leido.
public struct ChapterRowView: View {
    public let chapter: Chapter
    public let isCurrentProgress: Bool
    public let onSelect: () -> Void

    public init(chapter: Chapter, isCurrentProgress: Bool = false, onSelect: @escaping () -> Void) {
        self.chapter = chapter
        self.isCurrentProgress = isCurrentProgress
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Indicador visual de leido o en progreso
                ZStack {
                    if isCurrentProgress {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 28, height: 28)
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    } else if chapter.isRead {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.green)
                    } else {
                        Circle()
                            .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 28, height: 28)
                    }
                }

                // Titulo del capitulo y metadatos
                VStack(alignment: .leading, spacing: 3) {
                    Text(chapter.fullDisplayTitle)
                        .font(.subheadline.weight(chapter.isRead ? .regular : .semibold))
                        .foregroundStyle(chapter.isRead ? .secondary : .primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let group = chapter.scanlationGroup {
                            Text(group)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        if let date = chapter.formattedPublishedDate {
                            Text("• \(date)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isCurrentProgress ? Color.accentColor.opacity(0.08) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
