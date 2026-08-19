import SwiftUI
import SwiftData

/// Lector Pagina a Pagina con soporte de direccion Japonesa (Derecha -> Izquierda) y Occidental (Izquierda -> Derecha).
public struct PagedMangaReaderView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: ReaderViewModel
    public let pages: [Page]

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pagina activa
                if pages.indices.contains(viewModel.currentPageIndex) {
                    let page = pages[viewModel.currentPageIndex]

                    AsyncImage(url: page.imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        case .failure:
                            VStack(spacing: 10) {
                                Image(systemName: "photo.badge.exclamationmark")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.red)
                                Text("Error al cargar la página \(page.index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // Zonas tactiles invisibles (Izquierda, Centro, Derecha)
                HStack(spacing: 0) {
                    // Zona Izquierda (30% ancho)
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: geometry.size.width * 0.3)
                        .onTapGesture {
                            handleTap(onLeftSide: true)
                        }

                    // Zona Central (40% ancho) - Muestra/oculta controles
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: geometry.size.width * 0.4)
                        .onTapGesture {
                            viewModel.toggleControls()
                        }

                    // Zona Derecha (30% ancho)
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: geometry.size.width * 0.3)
                        .onTapGesture {
                            handleTap(onLeftSide: false)
                        }
                }

                // Indicador flotante sutil de pagina
                if !viewModel.isControlsVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(viewModel.currentPageIndex + 1) / \(pages.count)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Capsule())
                                .padding(.trailing, 16)
                                .padding(.bottom, 16)
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 25)
                    .onEnded { value in
                        if value.translation.width < -30 {
                            // Deslizamiento hacia la izquierda
                            if viewModel.readingDirection == .rightToLeft {
                                turnPageForward()
                            } else {
                                turnPageForward()
                            }
                        } else if value.translation.width > 30 {
                            // Deslizamiento hacia la derecha
                            turnPageBackward()
                        }
                    }
            )
        }
    }

    private func handleTap(onLeftSide: Bool) {
        if viewModel.readingDirection == .rightToLeft {
            // Modo Japones: Tocar a la izquierda avanza de pagina
            if onLeftSide {
                turnPageForward()
            } else {
                turnPageBackward()
            }
        } else {
            // Modo Occidental: Tocar a la derecha avanza de pagina
            if onLeftSide {
                turnPageBackward()
            } else {
                turnPageForward()
            }
        }
    }

    private func turnPageForward() {
        if viewModel.currentPageIndex < pages.count - 1 {
            viewModel.changePage(to: viewModel.currentPageIndex + 1, context: modelContext)
        } else if viewModel.hasNextChapter {
            Task { await viewModel.goToNextChapter(context: modelContext) }
        }
    }

    private func turnPageBackward() {
        if viewModel.currentPageIndex > 0 {
            viewModel.changePage(to: viewModel.currentPageIndex - 1, context: modelContext)
        } else if viewModel.hasPreviousChapter {
            Task { await viewModel.goToPreviousChapter(context: modelContext) }
        }
    }
}
