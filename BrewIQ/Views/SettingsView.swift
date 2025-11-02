//
//  SettingsView.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var preferences: [UserPreferences]
    
    @State private var showingAddCustomMethod = false
    @State private var editingMethod: BrewMethod?
    
    private var userPrefs: UserPreferences {
        if let prefs = preferences.first {
            return prefs
        } else {
            let newPrefs = UserPreferences()
            modelContext.insert(newPrefs)
            return newPrefs
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Method Selection Section
                Section {
                    ForEach(BrewMethod.allCases) { method in
                        MethodSelectionRow(
                            method: method,
                            isSelected: userPrefs.selectedMethodRawValues.contains(method.rawValue),
                            canSelect: userPrefs.selectedMethodRawValues.count < 6 || userPrefs.selectedMethodRawValues.contains(method.rawValue),
                            onToggle: { toggleMethod(method) },
                            onEdit: { editingMethod = method }
                        )
                    }
                } header: {
                    Text("Select Brew Methods (Max 6)")
                } footer: {
                    Text("Choose up to 6 brew methods to display in the calculator")
                }
                
                // Custom Methods Section
                Section {
                    Button(action: { showingAddCustomMethod = true }) {
                        Label("Add Custom Method", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Custom Methods")
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingMethod) { method in
                RatioEditorView(method: method, preferences: userPrefs)
            }
            .sheet(isPresented: $showingAddCustomMethod) {
                AddCustomMethodView(preferences: userPrefs)
            }
        }
    }
    
    private func toggleMethod(_ method: BrewMethod) {
        if userPrefs.selectedMethodRawValues.contains(method.rawValue) {
            userPrefs.selectedMethodRawValues.removeAll { $0 == method.rawValue }
        } else if userPrefs.selectedMethodRawValues.count < 6 {
            userPrefs.selectedMethodRawValues.append(method.rawValue)
        }
    }
}

// MARK: - Method Selection Row
struct MethodSelectionRow: View {
    let method: BrewMethod
    let isSelected: Bool
    let canSelect: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Image(systemName: method.icon)
                        .foregroundStyle(Color.brewPrimary)
                        .frame(width: 24)
                    
                    Text(method.rawValue)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color.brewPrimary : .secondary)
                }
            }
            .disabled(!canSelect && !isSelected)
            .opacity((!canSelect && !isSelected) ? 0.5 : 1)
            
            Button(action: onEdit) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Color.brewAccent)
            }
        }
    }
}

// MARK: - Ratio Editor View
struct RatioEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let method: BrewMethod
    let preferences: UserPreferences
    
    @State private var mildRatio: String
    @State private var mediumRatio: String
    @State private var boldRatio: String
    
    init(method: BrewMethod, preferences: UserPreferences) {
        self.method = method
        self.preferences = preferences
        
        let mild = preferences.getRatio(for: method, strength: .mild)
        let medium = preferences.getRatio(for: method, strength: .medium)
        let bold = preferences.getRatio(for: method, strength: .bold)
        
        _mildRatio = State(initialValue: String(format: "%.1f", mild))
        _mediumRatio = State(initialValue: String(format: "%.1f", medium))
        _boldRatio = State(initialValue: String(format: "%.1f", bold))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Mild (1:x)")
                        Spacer()
                        TextField("Ratio", text: $mildRatio)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Medium (1:x)")
                        Spacer()
                        TextField("Ratio", text: $mediumRatio)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Bold (1:x)")
                        Spacer()
                        TextField("Ratio", text: $boldRatio)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                } header: {
                    Text("Custom Ratios for \(method.rawValue)")
                }
                
                Section {
                    Button(action: resetToDefaults) {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(Color.brewAccent)
                    }
                }
            }
            .navigationTitle("Edit Ratios")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRatios()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveRatios() {
        guard let mild = Double(mildRatio),
              let medium = Double(mediumRatio),
              let bold = Double(boldRatio) else { return }
        
        preferences.customRatios[method.rawValue] = CustomRatio(
            mild: mild,
            medium: medium,
            bold: bold
        )
    }
    
    private func resetToDefaults() {
        preferences.customRatios.removeValue(forKey: method.rawValue)
        mildRatio = String(format: "%.1f", method.ratio(for: .mild))
        mediumRatio = String(format: "%.1f", method.ratio(for: .medium))
        boldRatio = String(format: "%.1f", method.ratio(for: .bold))
    }
}

// MARK: - Add Custom Method View
struct AddCustomMethodView: View {
    @Environment(\.dismiss) private var dismiss
    let preferences: UserPreferences
    
    @State private var methodName = ""
    @State private var mildRatio = "17"
    @State private var mediumRatio = "16"
    @State private var boldRatio = "15"
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Method Name", text: $methodName)
                        .autocorrectionDisabled()
                } header: {
                    Text("Method Details")
                } footer: {
                    Text("Keep it short to fit in the button")
                }
                
                Section {
                    HStack {
                        Text("Mild (1:x)")
                        Spacer()
                        TextField("Ratio", text: $mildRatio)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Medium (1:x)")
                        Spacer()
                        TextField("Ratio", text: $mediumRatio)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Bold (1:x)")
                        Spacer()
                        TextField("Ratio", text: $boldRatio)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                } header: {
                    Text("Ratios")
                }
            }
            .navigationTitle("Add Custom Method")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCustomMethod()
                        dismiss()
                    }
                    .disabled(methodName.isEmpty)
                }
            }
        }
    }
    
    private func addCustomMethod() {
        guard let mild = Double(mildRatio),
              let medium = Double(mediumRatio),
              let bold = Double(boldRatio) else { return }
        
        let customMethod = CustomBrewMethodData(
            name: methodName,
            ratioMild: mild,
            ratioMedium: medium,
            ratioBold: bold
        )
        preferences.customMethods.append(customMethod)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
}
