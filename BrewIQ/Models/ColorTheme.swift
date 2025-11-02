//
//  ColorTheme.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI

extension Color {
    // Cherry Blossom Latte Color Palette with Dark Mode Support
    
    // Primary - Rose pink (light) / Deeper rose (dark)
    static let brewPrimary = Color(light: Color(red: 0.8, green: 0.5, blue: 0.5),
                                    dark: Color(red: 0.9, green: 0.6, blue: 0.6))
    
    // Secondary - Cream (light) / Muted cocoa (dark)
    static let brewSecondary = Color(light: Color(red: 0.95, green: 0.9, blue: 0.88),
                                      dark: Color(red: 0.3, green: 0.25, blue: 0.23))
    
    // Accent - Cocoa (light & dark adaptive)
    static let brewAccent = Color(light: Color(red: 0.5, green: 0.35, blue: 0.3),
                                   dark: Color(red: 0.85, green: 0.65, blue: 0.55))
    
    // Card background - Soft cream (light) / Dark cocoa (dark)
    static let brewCardBackground = Color(light: Color(red: 0.98, green: 0.95, blue: 0.93),
                                           dark: Color(red: 0.25, green: 0.2, blue: 0.18))
    
    // Text on colored backgrounds - Always high contrast
    static let brewTextOnPrimary = Color.white
    
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
