//
//  BrewCalculatorViewModel.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation
import SwiftUI

@Observable
class BrewCalculatorViewModel {
    var selectedMethod: BrewMethod = .frenchPress
    var selectedStrength: BrewStrength = .medium
    var selectedWaterUnit: WaterUnit = .milliliters
    
    var coffeeInput: String = ""
    var waterInput: String = ""
    
    // Coffee is always in grams
    var calculatedCoffee: Double? {
        guard let water = Double(waterInput), water > 0 else { return nil }
        let ratio = selectedMethod.ratio(for: selectedStrength)
        let waterInGrams = selectedWaterUnit.toGrams(water)
        return waterInGrams / ratio // Returns grams of coffee
    }
    
    // Water calculated in selected unit
    var calculatedWater: Double? {
        guard let coffee = Double(coffeeInput), coffee > 0 else { return nil }
        let ratio = selectedMethod.ratio(for: selectedStrength)
        let waterInGrams = coffee * ratio // Coffee input is always in grams
        return selectedWaterUnit.fromMilliliters(waterInGrams) // 1g water ≈ 1ml
    }
    
    func clearInputs() {
        coffeeInput = ""
        waterInput = ""
    }
    
    func formatValue(_ value: Double?) -> String {
        guard let value = value else { return "--" }
        return String(format: "%.1f", value)
    }
}
