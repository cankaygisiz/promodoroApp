import SwiftUI

enum AppTheme {
    // Primary colors - Cyan and Orange
    static let cyan = Color(red: 0.0, green: 0.8, blue: 0.9)
    static let cyanLight = Color(red: 0.4, green: 0.9, blue: 1.0)
    static let cyanDark = Color(red: 0.0, green: 0.6, blue: 0.7)
    
    static let orange = Color(red: 1.0, green: 0.5, blue: 0.2)
    static let orangeLight = Color(red: 1.0, green: 0.65, blue: 0.4)
    static let orangeDark = Color(red: 0.85, green: 0.35, blue: 0.1)
    
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
