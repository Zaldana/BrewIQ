//
//  CustomizationView.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI
import SwiftData

struct CustomizationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    
    @State private var selectedMethodRawValues: [String] = []
    @State private var customRatios: [String: CustomRatio] = [:]
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
        List {
                // Method Selection Section
                Section {
                    ForEach(BrewMethod.allCases) { method in
                        MethodSelectionRow(
                            method: method,
                            isSelected: selectedMethodRawValues.contains(method.rawValue),
                            onToggle: { toggleMethod(method) }
                        )
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Select Brew Methods")
                        Text("Choose up to 6 methods to display")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.none)
                    }
                }
                
                // Customize Ratios Section
                Section("Customize Ratios") {
                    ForEach(selectedMethodRawValues.compactMap { BrewMethod(rawValue: $0) }) { method in
                        Button {
                            editingMethod = method
                        } label: {
                            HStack {
                                Image(systemName: method.icon)
                                    .foregroundStyle(Color.brewPrimary)
                                Text(method.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if customRatios[method.rawValue] != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.caption)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // Custom Methods Section
                Section("Custom Brew Methods") {
                    Button {
                        showingAddCustomMethod = true
                    } label: {
                        Label("Add Custom Method", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.brewPrimary)
                    }
                    
                    ForEach(userPrefs.customMethods, id: \.id) { customMethod in
                        HStack {
                            Image(systemName: customMethod.icon)
                            Text(customMethod.name)
                            Spacer()
                            Text("1:\(String(format: "%.1f", customMethod.ratioMedium))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        deleteCustomMethods(at: indexSet)
                    }
                }
        }
        .navigationTitle("Customize")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(item: $editingMethod) { method in
            RatioEditorView(
                method: method,
                customRatio: customRatios[method.rawValue],
                onSave: { ratio in
                    customRatios[method.rawValue] = ratio
                    savePreferences()
                },
                onReset: {
                    customRatios.removeValue(forKey: method.rawValue)
                    savePreferences()
                }
            )
        }
        .sheet(isPresented: $showingAddCustomMethod) {
            AddCustomMethodView { customMethod in
                userPrefs.customMethods.append(customMethod)
                try? modelContext.save()
            }
        }
        .onAppear {
            selectedMethodRawValues = userPrefs.selectedMethodRawValues
            customRatios = userPrefs.customRatios
        }
        .onDisappear {
            savePreferences()
        }
    }
    
    private func toggleMethod(_ method: BrewMethod) {
        if let index = selectedMethodRawValues.firstIndex(of: method.rawValue) {
            selectedMethodRawValues.remove(at: index)
        } else if selectedMethodRawValues.count < 6 {
            selectedMethodRawValues.append(method.rawValue)
        }
    }
    
    private func savePreferences() {
        userPrefs.selectedMethodRawValues = selectedMethodRawValues
        userPrefs.customRatios = customRatios
        try? modelContext.save()
    }
    
    private func deleteCustomMethods(at indexSet: IndexSet) {
        indexSet.forEach { index in
            userPrefs.customMethods.remove(at: index)
        }
    }
}

// MARK: - Method Selection Row
struct MethodSelectionRow: View {
    let method: BrewMethod
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: method.icon)
                    .foregroundStyle(isSelected ? Color.brewPrimary : .secondary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .foregroundStyle(.primary)
                    Text("Mild: 1:\(String(format: "%.1f", method.ratio(for: .mild))) • Medium: 1:\(String(format: "%.1f", method.ratio(for: .medium))) • Bold: 1:\(String(format: "%.1f", method.ratio(for: .bold)))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.brewPrimary)
                }
            }
        }
    }
}

// MARK: - Ratio Editor View
struct RatioEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let method: BrewMethod
    let customRatio: CustomRatio?
    let onSave: (CustomRatio) -> Void
    let onReset: () -> Void
    
    @State private var mildRatio: String = ""
    @State private var mediumRatio: String = ""
    @State private var boldRatio: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: method.icon)
                            .font(.title2)
                            .foregroundStyle(Color.brewPrimary)
                        Text(method.rawValue)
                            .font(.headline)
                    }
                }
                
                Section("Default Ratios") {
                    RatioInfoRow(label: "Mild", ratio: method.ratio(for: .mild))
                    RatioInfoRow(label: "Medium", ratio: method.ratio(for: .medium))
                    RatioInfoRow(label: "Bold", ratio: method.ratio(for: .bold))
                }
                
                Section("Custom Ratios") {
                    RatioInputRow(label: "Mild", ratio: $mildRatio)
                    RatioInputRow(label: "Medium", ratio: $mediumRatio)
                    RatioInputRow(label: "Bold", ratio: $boldRatio)
                }
                
                Section {
                    Button(role: .destructive) {
                        onReset()
                        dismiss()
                    } label: {
                        Label("Reset to Default", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Edit Ratios")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let mild = Double(mildRatio),
                           let medium = Double(mediumRatio),
                           let bold = Double(boldRatio) {
                            onSave(CustomRatio(mild: mild, medium: medium, bold: bold))
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let custom = customRatio {
                    mildRatio = String(format: "%.1f", custom.mild)
                    mediumRatio = String(format: "%.1f", custom.medium)
                    boldRatio = String(format: "%.1f", custom.bold)
                } else {
                    mildRatio = String(format: "%.1f", method.ratio(for: .mild))
                    mediumRatio = String(format: "%.1f", method.ratio(for: .medium))
                    boldRatio = String(format: "%.1f", method.ratio(for: .bold))
                }
            }
        }
    }
    
    private var isValid: Bool {
        Double(mildRatio) != nil && Double(mediumRatio) != nil && Double(boldRatio) != nil
    }
}

struct RatioInfoRow: View {
    let label: String
    let ratio: Double
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("1 : \(String(format: "%.1f", ratio))")
                .foregroundStyle(.secondary)
        }
    }
}

struct RatioInputRow: View {
    let label: String
    @Binding var ratio: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("1 :")
                .foregroundStyle(.secondary)
            TextField("Ratio", text: $ratio)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
        }
    }
}

// MARK: - Add Custom Method View
struct AddCustomMethodView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (CustomBrewMethodData) -> Void
    
    @State private var methodName: String = ""
    @State private var mildRatio: String = "17.0"
    @State private var mediumRatio: String = "16.0"
    @State private var boldRatio: String = "15.0"
    @State private var selectedIcon: String = "mug.fill"
    
    let availableIcons = ["mug.fill", "cup.and.saucer.fill", "drop.fill", "sparkles", "star.fill", "heart.fill", "leaf.fill", "flame.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Method Name") {
                    TextField("e.g., My Special Brew", text: $methodName)
                        .autocorrectionDisabled()
                }
                
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 60, height: 60)
                                    .background(selectedIcon == icon ? Color.brewPrimary : Color.brewSecondary)
                                    .foregroundStyle(selectedIcon == icon ? Color.brewTextOnPrimary : .primary)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Ratios (Water : Coffee)") {
                    RatioInputRow(label: "Mild", ratio: $mildRatio)
                    RatioInputRow(label: "Medium", ratio: $mediumRatio)
                    RatioInputRow(label: "Bold", ratio: $boldRatio)
                }
            }
            .navigationTitle("Add Custom Method")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let mild = Double(mildRatio),
                           let medium = Double(mediumRatio),
                           let bold = Double(boldRatio) {
                            let customMethod = CustomBrewMethodData(
                                name: methodName,
                                icon: selectedIcon,
                                ratioMild: mild,
                                ratioMedium: medium,
                                ratioBold: bold
                            )
                            onSave(customMethod)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !methodName.isEmpty &&
        methodName.count <= 15 &&
        Double(mildRatio) != nil &&
        Double(mediumRatio) != nil &&
        Double(boldRatio) != nil
    }
}

#Preview {
    CustomizationView()
}
