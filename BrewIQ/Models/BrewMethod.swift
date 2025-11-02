//
//  BrewMethod.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation

enum BrewMethod: String, CaseIterable, Codable, Identifiable {
    case pourOver = "Pour Over"
    case frenchPress = "French Press"
    case aeroPress = "AeroPress"
    case harioV60 = "Hario V60"
    case chemex = "Chemex"
    case kalitaWave = "Kalita Wave"
    case cleverDripper = "Clever Dripper"
    case siphonCoffee = "Siphon Coffee"
    case vacuumCoffee = "Vacuum Coffee"
    case mokaPot = "Moka Pot"
    case dripCoffee = "Drip Coffee"
    case percolation = "Percolation"
    
    var id: String { rawValue }
    
    // Get ratio for specific strength (water:coffee)
    func ratio(for strength: BrewStrength) -> Double {
        switch self {
        case .pourOver, .harioV60, .chemex, .kalitaWave:
            return strength == .mild ? 17 : (strength == .medium ? 16 : 15)
        case .frenchPress:
            return strength == .mild ? 17 : (strength == .medium ? 15 : 13)
        case .aeroPress:
            return strength == .mild ? 15 : (strength == .medium ? 13 : 11)
        case .cleverDripper:
            return strength == .mild ? 17 : (strength == .medium ? 16 : 15)
        case .siphonCoffee:
            return strength == .mild ? 17 : (strength == .medium ? 16 : 14)
        case .vacuumCoffee:
            return strength == .mild ? 17 : (strength == .medium ? 15.5 : 14)
        case .mokaPot:
            return strength == .mild ? 12 : (strength == .medium ? 10 : 8)
        case .dripCoffee:
            return strength == .mild ? 17 : (strength == .medium ? 16 : 15)
        case .percolation:
            return strength == .mild ? 18 : (strength == .medium ? 16 : 14)
        }
    }
    
    var icon: String {
        switch self {
        case .pourOver: return "drop.triangle"
        case .frenchPress: return "cup.and.saucer.fill"
        case .aeroPress: return "cylinder.fill"
        case .harioV60: return "cone.fill"
        case .chemex: return "flask.fill"
        case .kalitaWave: return "circle.grid.3x3.fill"
        case .cleverDripper: return "lightbulb.fill"
        case .siphonCoffee: return "wind"
        case .vacuumCoffee: return "tornado"
        case .mokaPot: return "flame.fill"
        case .dripCoffee: return "drop.triangle.fill"
        case .percolation: return "drop.fill"
        }
    }
}
