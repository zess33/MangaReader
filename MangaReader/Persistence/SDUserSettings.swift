import Foundation
import SwiftData

/// Entidad SwiftData para almacenar ajustes persistentes de usuario.
@Model
public final class SDUserSettings {
    @Attribute(.unique) public var id: String
    public var appearanceModeRawValue: String
    public var defaultReadingDirectionRawValue: String
    public var autoHideReaderControls: Bool
    public var prefetchAheadCount: Int
    public var enabledSourceIDs: [String]
    public var maxDiskCacheMB: Int

    public init(
        id: String = "user_settings_singleton",
        appearanceModeRawValue: String = "Sistema",
        defaultReadingDirectionRawValue: String = ReadingDirection.verticalWebtoon.rawValue,
        autoHideReaderControls: Bool = true,
        prefetchAheadCount: Int = 3,
        enabledSourceIDs: [String] = ["mock", "anilist", "mangadex"],
        maxDiskCacheMB: Int = 1024
    ) {
        self.id = id
        self.appearanceModeRawValue = appearanceModeRawValue
        self.defaultReadingDirectionRawValue = defaultReadingDirectionRawValue
        self.autoHideReaderControls = autoHideReaderControls
        self.prefetchAheadCount = prefetchAheadCount
        self.enabledSourceIDs = enabledSourceIDs
        self.maxDiskCacheMB = maxDiskCacheMB
    }
}
