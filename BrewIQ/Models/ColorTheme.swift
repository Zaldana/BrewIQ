//
//  ColorTheme.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI

extension Color {
    // Monochrome theme with mint blue accents
    
    // Primary - Mint blue accent color (optimized for WCAG AA contrast)
    static let brewPrimary = Color(light: Color(red: 0.15, green: 0.55, blue: 0.50),
                                    dark: Color(red: 0.3, green: 0.7, blue: 0.65),
                                    highContrastLight: Color(red: 0.1, green: 0.45, blue: 0.40),
                                    highContrastDark: Color(red: 0.4, green: 0.85, blue: 0.80))
    
    // Mint blue gradient colors (optimized for better contrast)
    static let brewPrimaryGradientStart = Color(light: Color(red: 0.1, green: 0.45, blue: 0.40),
                                                 dark: Color(red: 0.25, green: 0.6, blue: 0.55),
                                                 highContrastLight: Color(red: 0.05, green: 0.35, blue: 0.30),
                                                 highContrastDark: Color(red: 0.35, green: 0.75, blue: 0.70))
    static let brewPrimaryGradientEnd = Color(light: Color(red: 0.2, green: 0.65, blue: 0.60),
                                               dark: Color(red: 0.35, green: 0.8, blue: 0.75),
                                               highContrastLight: Color(red: 0.15, green: 0.55, blue: 0.50),
                                               highContrastDark: Color(red: 0.45, green: 0.95, blue: 0.90))
    
    // Secondary - Grey tones with better contrast
    static let brewSecondary = Color(light: Color.gray.opacity(0.4),
                                      dark: Color.gray.opacity(0.4),
                                      highContrastLight: Color.gray.opacity(0.6),
                                      highContrastDark: Color.gray.opacity(0.6))
    
    // Accent - Mint blue (optimized for contrast)
    static let brewAccent = Color(light: Color(red: 0.15, green: 0.55, blue: 0.50),
                                   dark: Color(red: 0.3, green: 0.7, blue: 0.65),
                                   highContrastLight: Color(red: 0.1, green: 0.45, blue: 0.40),
                                   highContrastDark: Color(red: 0.4, green: 0.85, blue: 0.80))
    
    // Card background - Pure white/black in high contrast
    static let brewCardBackground = Color(light: Color.white.opacity(0.95),
                                           dark: Color.black.opacity(0.85),
                                           highContrastLight: Color.white,
                                           highContrastDark: Color.black)
    
    // Text on colored backgrounds - Guaranteed contrast
    static let brewTextOnPrimary = Color.white
    
    // Background gradient colors
    static let brewBackgroundTop = Color(light: Color(white: 0.96), 
                                          dark: Color(white: 0.05),
                                          highContrastLight: Color.white,
                                          highContrastDark: Color.black)
    static let brewBackgroundBottom = Color(light: Color(white: 0.92), 
                                             dark: Color(white: 0.0),
                                             highContrastLight: Color(white: 0.95),
                                             highContrastDark: Color.black)
    
    // Helper initializer for light/dark mode with high contrast support
    private init(light: Color, dark: Color, highContrastLight: Color? = nil, highContrastDark: Color? = nil) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            let isDark = traitCollection.userInterfaceStyle == .dark
            let isHighContrast = traitCollection.accessibilityContrast == .high
            
            if isDark && isHighContrast, let hcDark = highContrastDark {
                return UIColor(hcDark)
            } else if !isDark && isHighContrast, let hcLight = highContrastLight {
                return UIColor(hcLight)
            } else if isDark {
                return UIColor(dark)
            } else {
                return UIColor(light)
            }
        })
        #else
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.name == .darkAqua
            let isHighContrast = appearance.bestMatch(from: [.accessibilityHighContrastAqua, .accessibilityHighContrastDarkAqua]) != nil
            
            if isDark && isHighContrast, let hcDark = highContrastDark {
                return NSColor(hcDark)
            } else if !isDark && isHighContrast, let hcLight = highContrastLight {
                return NSColor(hcLight)
            } else if isDark {
                return NSColor(dark)
            } else {
                return NSColor(light)
            }
        })
        #endif
    }
}

extension LinearGradient {
    // Mint blue gradient
    static let brewPrimaryGradient = LinearGradient(
        colors: [.brewPrimaryGradientStart, .brewPrimaryGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
