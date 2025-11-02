//
//  BrewMethod.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation

enum BrewMethod: String, CaseIterable, Codable, Identifiable {
    case percolation = "Percolation"
    case frenchPress = "French Press"
    case mokaPot = "Moka Pot"
    case pourOver = "Pour Over"
    case dripCoffee = "Drip Coffee"
    case aeroPress = "AeroPress"
    
    var id: String { rawValue }
    
    // Default timer duration in seconds
    var defaultTime: TimeInterval {
        switch self {
        case .percolation: return 300  // 5:00
        case .frenchPress: return 240  // 4:00
        case .mokaPot: return 180      // 3:00
        case .pourOver: return 210     // 3:30
        case .dripCoffee: return 210   // 3:30
        case .aeroPress: return 120    // 2:00
        }
    }
    
    // Get ratio for specific strength (water:coffee)
    func ratio(for strength: BrewStrength) -> Double {
        switch self {
        case .percolation:
            return strength == .mild ? 18 : (strength == .medium ? 16 : 14)
        case .frenchPress:
            return strength == .mild ? 17 : (strength == .medium ? 15 : 13)
        case .mokaPot:
            return strength == .mild ? 12 : (strength == .medium ? 10 : 8)
        case .pourOver:
            return strength == .mild ? 17 : (strength == .medium ? 16 : 15)
        case .dripCoffee:
            return strength == .mild ? 17 : (strength == .medium ? 16 : 15)
        case .aeroPress:
            return strength == .mild ? 15 : (strength == .medium ? 13 : 11)
        }
    }
    
    var icon: String {
        switch self {
        case .percolation: return "drop.fill"
        case .frenchPress: return "cup.and.saucer.fill"
        case .mokaPot: return "flame.fill"
        case .pourOver: return "drop.triangle"
        case .dripCoffee: return "drop.triangle.fill"
        case .aeroPress: return "cylinder.fill"
        }
    }
}
