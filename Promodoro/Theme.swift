import SwiftUI

enum AppTheme {
    // Primary colors - Red and Green
    static let cyan = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let cyanLight = Color(red: 0.4, green: 0.9, blue: 0.5)
    static let cyanDark = Color(red: 0.1, green: 0.6, blue: 0.3)
    
    static let orange = Color(red: 0.9, green: 0.25, blue: 0.2)
    static let orangeLight = Color(red: 1.0, green: 0.4, blue: 0.35)
    static let orangeDark = Color(red: 0.75, green: 0.15, blue: 0.1)
    
    // Background colors
    static let backgroundDark = Color(red: 0.08, green: 0.1, blue: 0.12)
    static let backgroundLight = Color(red: 0.12, green: 0.14, blue: 0.16)
    
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    
    // Gradients
    static let cyanGradient = LinearGradient(
        colors: [cyanLight, cyan, cyanDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orangeGradient = LinearGradient(
        colors: [orangeLight, orange, orangeDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [backgroundDark, backgroundLight],
        startPoint: .top,
        endPoint: .bottom
    )
}
