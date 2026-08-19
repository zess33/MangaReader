import SwiftUI
import UIKit

/// Vista personalizada de SwiftUI para mostrar imagenes cacheadas en RAM/Disco con fade-in fluido.
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage? = nil
    @State private var isLoading: Bool = false

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .onChange(of: url) { _, _ in
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        // 1. Comprobar cache rapido
        if let cached = ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        // 2. Descargar de red
        guard !isLoading else { return }
        isLoading = true

        Task(priority: .userInitiated) {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let downloaded = UIImage(data: data) else {
                    isLoading = false
                    return
                }

                ImageCache.shared.insertImage(downloaded, for: url, data: data)
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.uiImage = downloaded
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
