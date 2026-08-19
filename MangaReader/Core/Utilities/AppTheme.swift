import SwiftUI

/// Paleta de colores y estilos optimizada para pantallas Super Retina XDR OLED (iPhone 13 Pro Max).
public enum AppTheme {
    public static let oledBackground = Color.black
    public static let cardBackground = Color(red: 0.08, green: 0.08, blue: 0.10)
    public static let elevatedBackground = Color(red: 0.12, green: 0.12, blue: 0.15)
    public static let primaryAccent = Color(red: 0.45, green: 0.35, blue: 0.95) // Morado moderno
    public static let secondaryAccent = Color(red: 0.20, green: 0.60, blue: 1.00) // Azul vibrante

    public static let cornerRadiusLarge: CGFloat = 16
    public static let cornerRadiusMedium: CGFloat = 12
    public static let cornerRadiusSmall: CGFloat = 8

    public static let smoothSpring = Animation.spring(response: 0.35, dampingFraction: 0.82)
}
