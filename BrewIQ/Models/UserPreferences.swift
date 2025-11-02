//
//  UserPreferences.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation
import SwiftData

@Model
final class UserPreferences {
    var selectedMethodRawValues: [String] // Store selected brew method IDs (max 6)
    var customRatios: [String: CustomRatio] // Method rawValue -> CustomRatio
    var customMethods: [CustomBrewMethodData]
    
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
        self.customMethods = []
    }
    
    var selectedMethods: [BrewMethod] {
        selectedMethodRawValues.compactMap { BrewMethod(rawValue: $0) }
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
