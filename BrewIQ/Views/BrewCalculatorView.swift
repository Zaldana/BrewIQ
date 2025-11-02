//
//  BrewCalculatorView.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI
import SwiftData

struct BrewCalculatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var viewModel = BrewCalculatorViewModel()
    
    private var userPrefs: UserPreferences {
        if let prefs = preferences.first {
            return prefs
        } else {
            let newPrefs = UserPreferences()
            modelContext.insert(newPrefs)
            return newPrefs
        }
    }
    
    private var availableMethods: [BrewMethod] {
        userPrefs.selectedMethods
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Brew Method Selection - Compact Grid
                VStack(alignment: .leading, spacing: 8) {
                    Text("Brew Method")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(availableMethods) { method in
                            CompactMethodButton(
                                method: method,
                                ratio: userPrefs.getRatio(for: method, strength: viewModel.selectedStrength),
                                isSelected: viewModel.selectedMethod == method
                            ) {
                                viewModel.selectedMethod = method
                                viewModel.clearInputs()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Strength Selection with Ratios
                VStack(alignment: .leading, spacing: 8) {
                    Text("Strength")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        ForEach(BrewStrength.allCases) { strength in
                            CompactStrengthButton(
                                strength: strength,
                                ratio: userPrefs.getRatio(for: viewModel.selectedMethod, strength: strength),
                                isSelected: viewModel.selectedStrength == strength
                            ) {
                                viewModel.selectedStrength = strength
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Calculator Card - Compact
                VStack(spacing: 12) {
                    // Coffee Input - shows calculated value when water is entered
                    InputCard(
                        label: "Coffee",
                        unit: "g",
                        input: $viewModel.coffeeInput,
                        calculatedValue: viewModel.calculatedCoffee,
                        onEdit: { viewModel.waterInput = "" },
                        formatValue: viewModel.formatValue
                    )
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                        Text("OR")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 4)
                    
                    // Water Input with Unit Picker
                    VStack(spacing: 8) {
                        InputCard(
                            label: "Water",
                            unit: viewModel.selectedWaterUnit.rawValue,
                            input: $viewModel.waterInput,
                            calculatedValue: viewModel.calculatedWater,
                            onEdit: { viewModel.coffeeInput = "" },
                            formatValue: viewModel.formatValue
                        )
                        
                        // Water unit picker integrated
                        Picker("", selection: $viewModel.selectedWaterUnit) {
                            ForEach(WaterUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding()
                .background(Color.brewCardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer(minLength: 0)
                
                // Customize Button
                NavigationLink(destination: CustomizationView()) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Customize")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brewSecondary)
                    .foregroundStyle(Color.brewPrimary)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.top, 8)
        }
        .onAppear {
            // Set initial method if current one is not in selected methods
            if !availableMethods.isEmpty && !availableMethods.contains(viewModel.selectedMethod) {
                if let firstMethod = availableMethods.first {
                    viewModel.selectedMethod = firstMethod
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CompactMethodButton: View {
    let method: BrewMethod
    let ratio: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: method.icon)
                    .font(.title3)
                Text(method.rawValue)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(isSelected ? Color.brewPrimary : Color.brewSecondary)
            .foregroundStyle(isSelected ? Color.brewTextOnPrimary : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct CompactStrengthButton: View {
    let strength: BrewStrength
    let ratio: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(strength.rawValue)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                Text("1:\(String(format: "%.1f", ratio))")
                    .font(.caption)
                    .opacity(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color.brewPrimary : Color.brewSecondary)
            .foregroundStyle(isSelected ? Color.brewTextOnPrimary : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct InputCard: View {
    let label: String
    let unit: String
    @Binding var input: String
    let calculatedValue: Double?
    let onEdit: () -> Void
    let formatValue: (Double?) -> String
    
    // Computed property to determine display text
    private var displayText: String {
        if !input.isEmpty {
            return input
        } else if let value = calculatedValue {
            return formatValue(value)
        } else {
            return ""
        }
    }
    
    private var isCalculated: Bool {
        input.isEmpty && calculatedValue != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label.uppercased())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                if isCalculated {
                    // Show calculated value as non-editable text
                    Text(displayText)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.brewAccent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Show editable text field
                    TextField("0", text: $input)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .onChange(of: input) { onEdit() }
                }
                
                Text(unit)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.brewSecondary.opacity(0.3))
        .cornerRadius(12)
    }
}

#Preview {
    BrewCalculatorView()
}
