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
    
    var brewNotes: String {
        switch self {
        case .pourOver:
            return """
            • Grind: Medium-fine
            • Ratio: 1:16
            • Bloom 30s, then slow circular pours
            • Total: 3–4 min
            """
        case .frenchPress:
            return """
            • Grind: Coarse
            • Ratio: 1:15
            • Add water, stir, steep 4 min
            • Press slowly
            """
        case .aeroPress:
            return """
            • Grind: Fine-medium
            • Ratio: 1:14
            • Add water, stir 10s, steep 1 min
            • Press 20s
            """
        case .harioV60:
            return """
            • Grind: Medium-fine
            • Ratio: 1:15
            • Bloom 30s, slow spiral pours
            • Total: 2.5–3 min
            """
        case .chemex:
            return """
            • Grind: Medium-coarse
            • Ratio: 1:16
            • Bloom 45s, pour in stages
            • Total: 4–5 min
            """
        case .kalitaWave:
            return """
            • Grind: Medium
            • Ratio: 1:15
            • Bloom 30s, pulse pour evenly
            • Total: ~3 min
            """
        case .cleverDripper:
            return """
            • Grind: Medium
            • Ratio: 1:15
            • Add water, steep 2:30–3:00, drain
            • Total: ~3:30
            """
        case .siphonCoffee:
            return """
            • Grind: Medium
            • Ratio: 1:15
            • Heat until water rises, add coffee, stir
            • Brew 1 min, remove heat, let draw down
            """
        case .vacuumCoffee:
            return """
            • Grind: Medium
            • Ratio: 1:15
            • Heat, mix coffee, allow vacuum to pull down
            • Stop when drawdown is clean
            """
        case .mokaPot:
            return """
            • Grind: Fine (not espresso)
            • Ratio: ~1:7
            • Fill base (below valve), add basket
            • Brew on medium heat until hissing
            """
        case .dripCoffee:
            return """
            • Grind: Medium
            • Ratio: 1:15
            • Add water, grounds, and filter
            • Brew 4–6 min
            """
        case .percolation:
            return """
            • Grind: Medium-coarse
            • Ratio: 1:17
            • Add coffee basket, cold water
            • Heat gently, perk 5–7 min
            """
        }
    }
}
