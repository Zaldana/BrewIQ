//
//  CustomBrewMethod.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation
import SwiftData

@Model
final class CustomBrewMethod {
    var name: String
    var baseMethod: String // Store rawValue of BrewMethod
    var customRatioMild: Double
    var customRatioMedium: Double
    var customRatioBold: Double
    var customTime: TimeInterval
    var createdAt: Date
    
    init(name: String, baseMethod: BrewMethod, ratioMild: Double, ratioMedium: Double, ratioBold: Double, time: TimeInterval) {
        self.name = name
        self.baseMethod = baseMethod.rawValue
        self.customRatioMild = ratioMild
        self.customRatioMedium = ratioMedium
        self.customRatioBold = ratioBold
        self.customTime = time
        self.createdAt = Date()
    }
    
    func ratio(for strength: BrewStrength) -> Double {
        switch strength {
        case .mild: return customRatioMild
        case .medium: return customRatioMedium
        case .bold: return customRatioBold
        }
    }
}
