//
//  UserPreferences.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation
import SwiftData

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case auto = "Auto"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .auto: return "circle.lefthalf.filled"
        }
    }
}

@Model
final class UserPreferences {
    var selectedMethodRawValues: [String] // Store selected brew method IDs (max 6)
    var customRatios: [String: CustomRatio] // Method rawValue -> CustomRatio
    var customBrewNotes: [String: String] // Method rawValue -> Custom Notes
    var customMethods: [CustomBrewMethodData]
    var themeRawValue: String = AppTheme.auto.rawValue // Store theme preference with default
    
    init() {
        // Default: Curated 9 methods
        self.selectedMethodRawValues = [
            "French Press",
            "Moka Pot",
            "Drip Coffee",
            "AeroPress",
            "Siphon Coffee",
            "Chemex",
            "Hario V60",
            "Clever Dripper",
            "Pour Over"
        ]
        self.customRatios = [:]
        self.customBrewNotes = [:]
        self.customMethods = []
        self.themeRawValue = AppTheme.auto.rawValue
    }
    
    var selectedMethods: [BrewMethod] {
        selectedMethodRawValues.compactMap { BrewMethod(rawValue: $0) }
    }
    
    var theme: AppTheme {
        get { AppTheme(rawValue: themeRawValue) ?? .auto }
        set { themeRawValue = newValue.rawValue }
    }
    
    func getRatio(for method: BrewMethod, strength: BrewStrength) -> Double {
        if let customRatio = customRatios[method.rawValue] {
            switch strength {
            case .mild: return customRatio.mild
            case .medium: return customRatio.medium
            case .bold: return customRatio.bold
            }
        }
        return method.ratio(for: strength)
    }
    
    func getBrewNotes(for method: BrewMethod) -> String {
        return customBrewNotes[method.rawValue] ?? method.brewNotes
    }
}

// Store custom ratios
struct CustomRatio: Codable {
    var mild: Double
    var medium: Double
    var bold: Double
}

// Store custom brew method data
@Model
final class CustomBrewMethodData {
    var id: UUID
    var name: String
    var icon: String
    var ratioMild: Double
    var ratioMedium: Double
    var ratioBold: Double
    
    init(name: String, icon: String = "mug.fill", ratioMild: Double = 17, ratioMedium: Double = 16, ratioBold: Double = 15) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.ratioMild = ratioMild
        self.ratioMedium = ratioMedium
        self.ratioBold = ratioBold
    }
}
