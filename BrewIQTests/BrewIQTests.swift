//
//  BrewIQTests.swift
//  BrewIQTests
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Testing
@testable import BrewIQ

// MARK: - BrewMethod Tests
struct BrewMethodTests {
    
    @Test("Pour Over ratios for all strengths")
    func testPourOverRatios() {
        #expect(BrewMethod.pourOver.ratio(for: .mild) == 17)
        #expect(BrewMethod.pourOver.ratio(for: .medium) == 16)
        #expect(BrewMethod.pourOver.ratio(for: .bold) == 15)
    }
    
    @Test("French Press ratios for all strengths")
    func testFrenchPressRatios() {
        #expect(BrewMethod.frenchPress.ratio(for: .mild) == 17)
        #expect(BrewMethod.frenchPress.ratio(for: .medium) == 15)
        #expect(BrewMethod.frenchPress.ratio(for: .bold) == 13)
    }
    
    @Test("AeroPress ratios for all strengths")
    func testAeroPressRatios() {
        #expect(BrewMethod.aeroPress.ratio(for: .mild) == 15)
        #expect(BrewMethod.aeroPress.ratio(for: .medium) == 13)
        #expect(BrewMethod.aeroPress.ratio(for: .bold) == 11)
    }
    
    @Test("Moka Pot ratios for all strengths")
    func testMokaPotRatios() {
        #expect(BrewMethod.mokaPot.ratio(for: .mild) == 12)
        #expect(BrewMethod.mokaPot.ratio(for: .medium) == 10)
        #expect(BrewMethod.mokaPot.ratio(for: .bold) == 8)
    }
    
    @Test("All brew methods have unique IDs")
    func testBrewMethodIDs() {
        let methods = BrewMethod.allCases
        let ids = methods.map { $0.id }
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }
    
    @Test("All brew methods have icons")
    func testBrewMethodIcons() {
        for method in BrewMethod.allCases {
            #expect(!method.icon.isEmpty)
        }
    }
}

// MARK: - WaterUnit Tests
struct WaterUnitTests {
    
    @Test("Milliliters to milliliters conversion")
    func testMillilitersConversion() {
        let unit = WaterUnit.milliliters
        #expect(unit.toMilliliters(100) == 100)
        #expect(unit.fromMilliliters(100) == 100)
    }
    
    @Test("Ounces to milliliters conversion")
    func testOuncesConversion() {
        let unit = WaterUnit.ounces
        let ml = unit.toMilliliters(1)
        #expect(abs(ml - 29.5735) < 0.001)
        
        let oz = unit.fromMilliliters(29.5735)
        #expect(abs(oz - 1) < 0.001)
    }
    
    @Test("Cups to milliliters conversion")
    func testCupsConversion() {
        let unit = WaterUnit.cups
        let ml = unit.toMilliliters(1)
        #expect(abs(ml - 118.294) < 0.001)
        
        let cups = unit.fromMilliliters(118.294)
        #expect(abs(cups - 1) < 0.001)
    }
    
    @Test("Water to grams conversion")
    func testWaterToGramsConversion() {
        let unit = WaterUnit.milliliters
        #expect(unit.toGrams(250) == 250) // 1ml water ≈ 1g
    }
    
    @Test("All water units have display names")
    func testWaterUnitDisplayNames() {
        for unit in WaterUnit.allCases {
            #expect(!unit.displayName.isEmpty)
        }
    }
}

// MARK: - BrewCalculatorViewModel Tests
struct BrewCalculatorViewModelTests {
    
    @Test("Calculate coffee from water input")
    func testCalculateCoffeeFromWater() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.selectedMethod = .frenchPress
        viewModel.selectedStrength = .medium
        viewModel.selectedWaterUnit = .milliliters
        viewModel.waterInput = "300"
        
        let calculatedCoffee = viewModel.calculatedCoffee
        #expect(calculatedCoffee != nil)
        
        if let coffee = calculatedCoffee {
            // 300g water / 15 ratio = 20g coffee
            #expect(abs(coffee - 20) < 0.1)
        }
    }
    
    @Test("Calculate water from coffee input")
    func testCalculateWaterFromCoffee() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.selectedMethod = .frenchPress
        viewModel.selectedStrength = .medium
        viewModel.selectedWaterUnit = .milliliters
        viewModel.coffeeInput = "20"
        
        let calculatedWater = viewModel.calculatedWater
        #expect(calculatedWater != nil)
        
        if let water = calculatedWater {
            // 20g coffee * 15 ratio = 300ml water
            #expect(abs(water - 300) < 0.1)
        }
    }
    
    @Test("Calculate coffee with ounces water unit")
    func testCalculateCoffeeWithOunces() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.selectedMethod = .pourOver
        viewModel.selectedStrength = .medium
        viewModel.selectedWaterUnit = .ounces
        viewModel.waterInput = "10"
        
        let calculatedCoffee = viewModel.calculatedCoffee
        #expect(calculatedCoffee != nil)
        
        if let coffee = calculatedCoffee {
            // 10 oz = ~295.735 ml = ~295.735g water
            // 295.735g / 16 ratio ≈ 18.48g coffee
            #expect(abs(coffee - 18.48) < 0.5)
        }
    }
    
    @Test("Return nil for invalid water input")
    func testInvalidWaterInput() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.waterInput = "abc"
        
        #expect(viewModel.calculatedCoffee == nil)
    }
    
    @Test("Return nil for invalid coffee input")
    func testInvalidCoffeeInput() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.coffeeInput = "xyz"
        
        #expect(viewModel.calculatedWater == nil)
    }
    
    @Test("Return nil for zero water input")
    func testZeroWaterInput() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.waterInput = "0"
        
        #expect(viewModel.calculatedCoffee == nil)
    }
    
    @Test("Return nil for negative water input")
    func testNegativeWaterInput() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.waterInput = "-100"
        
        #expect(viewModel.calculatedCoffee == nil)
    }
    
    @Test("Clear inputs resets values")
    func testClearInputs() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.coffeeInput = "20"
        viewModel.waterInput = "300"
        
        viewModel.clearInputs()
        
        #expect(viewModel.coffeeInput.isEmpty)
        #expect(viewModel.waterInput.isEmpty)
    }
    
    @Test("Format value with one decimal place")
    func testFormatValue() {
        let viewModel = BrewCalculatorViewModel()
        
        #expect(viewModel.formatValue(20.5) == "20.5")
        #expect(viewModel.formatValue(20.123) == "20.1")
        #expect(viewModel.formatValue(20.99) == "21.0")
    }
    
    @Test("Format nil value returns placeholder")
    func testFormatNilValue() {
        let viewModel = BrewCalculatorViewModel()
        #expect(viewModel.formatValue(nil) == "--")
    }
    
    @Test("Different brew methods produce different coffee amounts")
    func testDifferentBrewMethods() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.selectedStrength = .medium
        viewModel.selectedWaterUnit = .milliliters
        viewModel.waterInput = "300"
        
        viewModel.selectedMethod = .frenchPress
        let frenchPressCoffee = viewModel.calculatedCoffee
        
        viewModel.selectedMethod = .aeroPress
        let aeroPressCoffee = viewModel.calculatedCoffee
        
        #expect(frenchPressCoffee != nil)
        #expect(aeroPressCoffee != nil)
        #expect(frenchPressCoffee != aeroPressCoffee)
    }
    
    @Test("Different brew strengths produce different coffee amounts")
    func testDifferentBrewStrengths() {
        let viewModel = BrewCalculatorViewModel()
        viewModel.selectedMethod = .frenchPress
        viewModel.selectedWaterUnit = .milliliters
        viewModel.waterInput = "300"
        
        viewModel.selectedStrength = .mild
        let mildCoffee = viewModel.calculatedCoffee
        
        viewModel.selectedStrength = .bold
        let boldCoffee = viewModel.calculatedCoffee
        
        #expect(mildCoffee != nil)
        #expect(boldCoffee != nil)
        // Bold should require more coffee
        if let mild = mildCoffee, let bold = boldCoffee {
            #expect(bold > mild)
        }
    }
}

// MARK: - BrewStrength Tests
struct BrewStrengthTests {
    
    @Test("All brew strengths have unique IDs")
    func testBrewStrengthIDs() {
        let strengths = BrewStrength.allCases
        let ids = strengths.map { $0.id }
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }
    
    @Test("Brew strength count")
    func testBrewStrengthCount() {
        #expect(BrewStrength.allCases.count == 3)
    }
}
