//
//  ColorTheme.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI

extension Color {
    // Monochrome theme with orange accents
    
    // Primary - Mint blue accent color (darker for better contrast)
    static let brewPrimary = Color(light: Color(red: 0.2, green: 0.6, blue: 0.55),
                                    dark: Color(red: 0.25, green: 0.65, blue: 0.6))
    
    // Mint blue gradient colors (darker for better contrast)
    static let brewPrimaryGradientStart = Color(light: Color(red: 0.15, green: 0.5, blue: 0.45),
                                                 dark: Color(red: 0.2, green: 0.55, blue: 0.5))
    static let brewPrimaryGradientEnd = Color(light: Color(red: 0.25, green: 0.7, blue: 0.65),
                                               dark: Color(red: 0.3, green: 0.75, blue: 0.7))
    
    // Secondary - Grey tones
    static let brewSecondary = Color(light: Color.gray.opacity(0.3),
                                      dark: Color.gray.opacity(0.3))
    
    // Accent - Mint blue (darker for better contrast)
    static let brewAccent = Color(light: Color(red: 0.2, green: 0.6, blue: 0.55),
                                   dark: Color(red: 0.25, green: 0.65, blue: 0.6))
    
    // Card background - White/Black with subtle grey
    static let brewCardBackground = Color(light: Color.white.opacity(0.9),
                                           dark: Color.black.opacity(0.8))
    
    // Text on colored backgrounds - White on orange
    static let brewTextOnPrimary = Color.white
    
    // Background gradient colors
    static let brewBackgroundTop = Color(light: Color(white: 0.95), dark: Color(white: 0.05))
    static let brewBackgroundBottom = Color(light: Color(white: 0.90), dark: Color(white: 0.0))
    
    // Helper initializer for light/dark mode
    private init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.name == .darkAqua ? NSColor(dark) : NSColor(light)
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
