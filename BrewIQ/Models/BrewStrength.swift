//
//  BrewStrength.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation

enum BrewStrength: String, CaseIterable, Codable, Identifiable {
    case mild = "Mild"
    case medium = "Medium"
    case bold = "Bold"
    
    var id: String { rawValue }
}
