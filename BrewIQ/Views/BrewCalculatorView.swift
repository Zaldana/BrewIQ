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
    @State private var isBrewNotesExpanded = false
    
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
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.brewBackgroundTop,
                        Color.brewBackgroundBottom
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                // App Title
                    Text("brewIQ")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .accessibilityAddTraits(.isHeader)
                
                // Calculator Card - Coffee and Water Fields
                VStack(spacing: 6) {
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
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 2)
                    
                    // Water Input with Unit Picker
                    VStack(spacing: 6) {
                        InputCard(
                            label: "Water",
                            unit: viewModel.selectedWaterUnit.rawValue,
                            input: $viewModel.waterInput,
                            calculatedValue: viewModel.calculatedWater,
                            onEdit: { viewModel.coffeeInput = "" },
                            formatValue: viewModel.formatValue
                        )
                        
                        // Water unit picker integrated
                        HStack(spacing: 8) {
                            ForEach(WaterUnit.allCases) { unit in
                                UnitPickerButton(
                                    label: unit.rawValue,
                                    isSelected: viewModel.selectedWaterUnit == unit
                                ) {
                                    viewModel.selectedWaterUnit = unit
                                }
                            }
                        }
                    }
                }
                .padding(14)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                // Strength Selection with Ratios
                VStack(alignment: .leading, spacing: 8) {
                    Text("Strength")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary.opacity(0.85))
                    
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
                
                // Brew Method Selection - Expanded Grid
                VStack(alignment: .leading, spacing: 8) {
                    Text("Brew Method")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary.opacity(0.85))
                        .padding(.horizontal)
                        
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
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
                
                // Brew Notes Accordion
                VStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isBrewNotesExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Brew Notes")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary.opacity(0.85))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.6))
                                .rotationEffect(.degrees(isBrewNotesExpanded ? 180 : 0))
                                .accessibilityHidden(true)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Brew Notes")
                    .accessibilityHint(isBrewNotesExpanded ? "Expanded. Tap to collapse" : "Collapsed. Tap to expand")
                    
                    if isBrewNotesExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(userPrefs.getBrewNotes(for: viewModel.selectedMethod))
                                .font(.body)
                                .foregroundStyle(.primary.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 0)
                
                // Customize Button
                NavigationLink(destination: CustomizationView()) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.body)
                            .accessibilityHidden(true)
                        Text("Customize")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 6)
                }
                .padding(.top, 8)
                }
            }
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
                    .fontWeight(.medium)
                    .accessibilityHidden(true)
                Text(method.rawValue)
                    .font(.footnote)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 70)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .background(.ultraThinMaterial)
            .foregroundStyle(isSelected ? Color.white : .primary)
            .cornerRadius(16)
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.45) : Color.black.opacity(0.075), 
                    radius: isSelected ? 15 : 4.5, x: 0, y: isSelected ? 7.5 : 2.25)
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.3) : Color.clear, 
                    radius: isSelected ? 7.5 : 0, x: 0, y: isSelected ? 3.75 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(method.rawValue), ratio 1 to \(String(format: "%.1f", ratio))")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Currently selected brew method" : "Tap to select this brew method")
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
                    .fontWeight(isSelected ? .semibold : .medium)
                Text("1:\(String(format: "%.1f", ratio))")
                    .font(.subheadline)
                    .opacity(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .background(.ultraThinMaterial)
            .foregroundStyle(isSelected ? Color.white : .primary)
            .cornerRadius(14)
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.45) : Color.black.opacity(0.075), 
                    radius: isSelected ? 12 : 3.75, x: 0, y: isSelected ? 6 : 1.5)
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.225) : Color.clear, 
                    radius: isSelected ? 6 : 0, x: 0, y: isSelected ? 3 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(strength.rawValue) strength, ratio 1 to \(String(format: "%.1f", ratio))")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Currently selected strength" : "Tap to select \(strength.rawValue) strength")
    }
}

struct UnitPickerButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .background(.ultraThinMaterial)
                .foregroundStyle(isSelected ? Color.white : .primary)
                .cornerRadius(10)
                .shadow(color: isSelected ? Color.brewPrimary.opacity(0.375) : Color.black.opacity(0.06), 
                        radius: isSelected ? 9 : 2.25, x: 0, y: isSelected ? 4.5 : 0.75)
                .shadow(color: isSelected ? Color.brewPrimary.opacity(0.225) : Color.clear, 
                        radius: isSelected ? 4.5 : 0, x: 0, y: isSelected ? 2.25 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Currently selected unit" : "Tap to select \(label) unit")
    }
}

struct InputCard: View {
    let label: String
    let unit: String
    @Binding var input: String
    let calculatedValue: Double?
    let onEdit: () -> Void
    let formatValue: (Double?) -> String
    @ScaledMetric private var inputFontSize: CGFloat = 32
    
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
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                if isCalculated {
                    // Show calculated value as non-editable text
                    Text(displayText)
                        .font(.system(size: inputFontSize, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Show editable text field
                    TextField("0", text: $input)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .font(.system(size: inputFontSize, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .onChange(of: input) { _, newValue in
                            // Only allow numbers and decimal point
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            // Ensure only one decimal point
                            let components = filtered.components(separatedBy: ".")
                            if components.count > 2 {
                                input = components[0] + "." + components[1...].joined()
                            } else {
                                input = filtered
                            }
                            onEdit()
                        }
                }
                
                Text(unit)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.brewPrimary)
            }
        }
        .padding(14)
        .background(.thinMaterial)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .tint(Color.brewPrimary)
    }
}

#Preview {
    BrewCalculatorView()
}
