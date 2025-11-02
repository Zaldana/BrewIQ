//
//  MeasurementUnit.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation

// Water units: milliliters, ounces, or 4 oz cups
enum WaterUnit: String, CaseIterable, Codable, Identifiable {
    case milliliters = "ml"
    case ounces = "oz"
    case cups = "cup (4oz)"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .milliliters: return "Milliliters"
        case .ounces: return "Ounces"
        case .cups: return "Cup (4oz)"
        }
    }
    
    // Convert to milliliters (base unit for water)
    func toMilliliters(_ value: Double) -> Double {
        switch self {
        case .milliliters: return value
        case .ounces: return value * 29.5735 // 1 fl oz = 29.5735 ml
        case .cups: return value * 118.294 // 1 cup (4 oz) = 118.294 ml
        }
    }
    
    // Convert from milliliters
    func fromMilliliters(_ value: Double) -> Double {
        switch self {
        case .milliliters: return value
        case .ounces: return value / 29.5735
        case .cups: return value / 118.294
        }
    }
    
    // Convert water to grams (1ml water ≈ 1g)
    func toGrams(_ value: Double) -> Double {
        return toMilliliters(value)
    }
}

// Coffee is always in grams
enum CoffeeUnit: String, Codable {
    case grams = "g"
    
    var displayName: String { "Grams" }
}
