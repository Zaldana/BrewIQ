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
    @State private var customBrewNotes: [String: String] = [:]
    @State private var showingAddCustomMethod = false
    @State private var selectedTheme: AppTheme = .auto
    @State private var isLoaded = false
    
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
            
        List {
                // Theme Selection Section
                Section {
                    HStack(spacing: 12) {
                        ForEach(AppTheme.allCases) { theme in
                            ThemeButton(
                                theme: theme,
                                isSelected: selectedTheme == theme,
                                onTap: {
                                    selectedTheme = theme
                                    savePreferences()
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Appearance")
                        Text("Choose your preferred theme")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .textCase(.none)
                    }
                }
                
                // Method Selection Section
                Section {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(BrewMethod.allCases) { method in
                            MethodSelectionButton(
                                method: method,
                                isSelected: selectedMethodRawValues.contains(method.rawValue),
                                onToggle: { toggleMethod(method) }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    .id(isLoaded)
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Select Brew Methods")
                        Text("Choose up to 9 methods to display")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .textCase(.none)
                    }
                }
                
                // Customize Ratios and Notes Section
                Section("Customize Ratios and Notes") {
                    ForEach(BrewMethod.allCases) { method in
                        CombinedCustomizationDisclosureGroup(
                            method: method,
                            customRatio: customRatios[method.rawValue],
                            customNotes: customBrewNotes[method.rawValue],
                            onSaveRatio: { ratio in
                                customRatios[method.rawValue] = ratio
                                savePreferences()
                            },
                            onResetRatio: {
                                customRatios.removeValue(forKey: method.rawValue)
                                savePreferences()
                            },
                            onSaveNotes: { notes in
                                customBrewNotes[method.rawValue] = notes
                                savePreferences()
                            },
                            onResetNotes: {
                                customBrewNotes.removeValue(forKey: method.rawValue)
                                savePreferences()
                            }
                        )
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
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(customMethod.name), ratio 1 to \(String(format: "%.1f", customMethod.ratioMedium))")
                    }
                    .onDelete { indexSet in
                        deleteCustomMethods(at: indexSet)
                    }
                }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Customize Ratios and Notes")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        }
        .sheet(isPresented: $showingAddCustomMethod) {
            AddCustomMethodView { customMethod in
                userPrefs.customMethods.append(customMethod)
                try? modelContext.save()
            }
        }
        .onAppear {
            loadPreferences()
            // Force view update after loading
            DispatchQueue.main.async {
                isLoaded.toggle()
            }
        }
        .onChange(of: userPrefs.selectedMethodRawValues) { _, newValue in
            selectedMethodRawValues = newValue
        }
        .onDisappear {
            savePreferences()
        }
    }
    
    private func toggleMethod(_ method: BrewMethod) {
        if let index = selectedMethodRawValues.firstIndex(of: method.rawValue) {
            selectedMethodRawValues.remove(at: index)
        } else if selectedMethodRawValues.count < 9 {
            selectedMethodRawValues.append(method.rawValue)
        }
    }
    
    private func loadPreferences() {
        selectedMethodRawValues = userPrefs.selectedMethodRawValues
        customRatios = userPrefs.customRatios
        customBrewNotes = userPrefs.customBrewNotes
        selectedTheme = userPrefs.theme
    }
    
    private func savePreferences() {
        userPrefs.selectedMethodRawValues = selectedMethodRawValues
        userPrefs.customRatios = customRatios
        userPrefs.customBrewNotes = customBrewNotes
        userPrefs.theme = selectedTheme
        try? modelContext.save()
    }
    
    private func deleteCustomMethods(at indexSet: IndexSet) {
        indexSet.forEach { index in
            userPrefs.customMethods.remove(at: index)
        }
    }
}

// MARK: - Method Selection Button
struct MethodSelectionButton: View {
    let method: BrewMethod
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 6) {
                Image(systemName: method.icon)
                    .font(.title3)
                    .accessibilityHidden(true)
                Text(method.rawValue)
                    .font(.footnote)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 80)
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
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.375) : Color.black.opacity(0.06), 
                    radius: isSelected ? 12 : 3, x: 0, y: isSelected ? 6 : 1.5)
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.225) : Color.clear, 
                    radius: isSelected ? 6 : 0, x: 0, y: isSelected ? 3 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(method.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Selected brew method" : "Tap to select this brew method")
    }
}

// MARK: - Combined Customization Disclosure Group
struct CombinedCustomizationDisclosureGroup: View {
    let method: BrewMethod
    let customRatio: CustomRatio?
    let customNotes: String?
    let onSaveRatio: (CustomRatio) -> Void
    let onResetRatio: () -> Void
    let onSaveNotes: (String) -> Void
    let onResetNotes: () -> Void
    
    @State private var mildRatio: String = ""
    @State private var mediumRatio: String = ""
    @State private var boldRatio: String = ""
    @State private var notesText: String = ""
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: method.icon)
                        .font(.title3)
                        .foregroundStyle(Color.brewPrimary)
                        .frame(width: 30)
                    Text(method.rawValue)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                    if customRatio != nil || customNotes != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.body)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 16) {
                    // RATIOS SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ratios")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.brewPrimary)
                        
                        // Default Ratios
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Default")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack {
                                RatioChip(label: "Mild", ratio: method.ratio(for: .mild))
                                RatioChip(label: "Medium", ratio: method.ratio(for: .medium))
                                RatioChip(label: "Bold", ratio: method.ratio(for: .bold))
                            }
                        }
                        
                        Divider()
                        
                        // Custom Ratios
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            RatioInputRow(label: "Mild", ratio: $mildRatio)
                                .padding(.vertical, 4)
                            RatioInputRow(label: "Medium", ratio: $mediumRatio)
                                .padding(.vertical, 4)
                            RatioInputRow(label: "Bold", ratio: $boldRatio)
                                .padding(.vertical, 4)
                        }
                        
                        // Ratio Action Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                onResetRatio()
                                loadDefaultRatios()
                            }) {
                                Text("Reset")
                                    .font(.body)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(.ultraThinMaterial)
                                    .foregroundStyle(Color.primary)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                if let mild = Double(mildRatio),
                                   let medium = Double(mediumRatio),
                                   let bold = Double(boldRatio) {
                                    onSaveRatio(CustomRatio(mild: mild, medium: medium, bold: bold))
                                }
                            }) {
                                Text("Apply")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        isRatioValid ? 
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) : LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(isRatioValid ? Color.white : Color.primary.opacity(0.6))
                                    .cornerRadius(12)
                                    .shadow(color: isRatioValid ? Color.brewPrimary.opacity(0.3) : Color.clear, 
                                            radius: isRatioValid ? 8 : 0, x: 0, y: isRatioValid ? 4 : 0)
                            }
                            .buttonStyle(.plain)
                            .disabled(!isRatioValid)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // BREW NOTES SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Brew Notes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.brewPrimary)
                        
                        // Notes Editor
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Edit your brew instructions")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            TextEditor(text: $notesText)
                                .font(.body)
                                .frame(minHeight: 120)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(.thinMaterial)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.brewPrimary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Notes Action Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                onResetNotes()
                                loadDefaultNotes()
                            }) {
                                Text("Reset")
                                    .font(.body)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(.ultraThinMaterial)
                                    .foregroundStyle(Color.primary)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                onSaveNotes(notesText)
                            }) {
                                Text("Apply")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        isNotesValid ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(isNotesValid ? Color.white : Color.primary.opacity(0.6))
                                    .cornerRadius(12)
                                    .shadow(color: isNotesValid ? Color.brewPrimary.opacity(0.3) : Color.clear, 
                                            radius: isNotesValid ? 8 : 0, x: 0, y: isNotesValid ? 4 : 0)
                            }
                            .buttonStyle(.plain)
                            .disabled(!isNotesValid)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.brewSecondary.opacity(0.3))
            }
        }
        .onAppear {
            loadDefaultRatios()
            loadDefaultNotes()
        }
    }
    
    private func loadDefaultRatios() {
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
    
    private func loadDefaultNotes() {
        notesText = customNotes ?? method.brewNotes
    }
    
    private var isRatioValid: Bool {
        Double(mildRatio) != nil && Double(mediumRatio) != nil && Double(boldRatio) != nil
    }
    
    private var isNotesValid: Bool {
        !notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Ratio Disclosure Group (Legacy - can be removed)
struct RatioDisclosureGroup: View {
    let method: BrewMethod
    let customRatio: CustomRatio?
    let onSave: (CustomRatio) -> Void
    let onReset: () -> Void
    
    @State private var mildRatio: String = ""
    @State private var mediumRatio: String = ""
    @State private var boldRatio: String = ""
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: method.icon)
                        .font(.title3)
                        .foregroundStyle(Color.brewPrimary)
                        .frame(width: 30)
                    Text(method.rawValue)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                    if customRatio != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.body)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 12) {
                // Default Ratios
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack {
                        RatioChip(label: "Mild", ratio: method.ratio(for: .mild))
                        RatioChip(label: "Medium", ratio: method.ratio(for: .medium))
                        RatioChip(label: "Bold", ratio: method.ratio(for: .bold))
                    }
                }
                
                Divider()
                
                // Custom Ratios
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    RatioInputRow(label: "Mild", ratio: $mildRatio)
                        .padding(.vertical, 4)
                    RatioInputRow(label: "Medium", ratio: $mediumRatio)
                        .padding(.vertical, 4)
                    RatioInputRow(label: "Bold", ratio: $boldRatio)
                        .padding(.vertical, 4)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        onReset()
                        loadDefaults()
                    }) {
                        Text("Reset")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .foregroundStyle(Color.primary)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        if let mild = Double(mildRatio),
                           let medium = Double(mediumRatio),
                           let bold = Double(boldRatio) {
                            onSave(CustomRatio(mild: mild, medium: medium, bold: bold))
                            isExpanded = false
                        }
                    }) {
                        Text("Apply")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                isValid ? 
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) : LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(isValid ? Color.white : Color.primary.opacity(0.6))
                            .cornerRadius(12)
                            .shadow(color: isValid ? Color.brewPrimary.opacity(0.3) : Color.clear, 
                                    radius: isValid ? 8 : 0, x: 0, y: isValid ? 4 : 0)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isValid)
                }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.brewSecondary.opacity(0.3))
            }
        }
        .onAppear {
            loadDefaults()
        }
    }
    
    private func loadDefaults() {
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
    
    private var isValid: Bool {
        Double(mildRatio) != nil && Double(mediumRatio) != nil && Double(boldRatio) != nil
    }
}

struct RatioChip: View {
    let label: String
    let ratio: Double
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("1:\(String(format: "%.1f", ratio))")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.brewSecondary.opacity(0.5))
        .cornerRadius(6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) ratio: 1 to \(String(format: "%.1f", ratio))")
    }
}

struct RatioInputRow: View {
    let label: String
    @Binding var ratio: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text("1 :")
                .font(.body)
                .foregroundStyle(.secondary)
            TextField("Ratio", text: $ratio)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .font(.body)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)
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

// MARK: - Brew Notes Disclosure Group
struct BrewNotesDisclosureGroup: View {
    let method: BrewMethod
    let customNotes: String?
    let onSave: (String) -> Void
    let onReset: () -> Void
    
    @State private var notesText: String = ""
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: method.icon)
                        .font(.title3)
                        .foregroundStyle(Color.brewPrimary)
                        .frame(width: 30)
                    Text(method.rawValue)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                    if customNotes != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.body)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 12) {
                    // Default Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(method.brewNotes)
                            .font(.body)
                            .foregroundStyle(.primary.opacity(0.8))
                            .lineSpacing(4)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.brewSecondary.opacity(0.5))
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Custom Notes Editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $notesText)
                            .font(.body)
                            .frame(minHeight: 100)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.brewPrimary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            onReset()
                            loadDefaults()
                        }) {
                            Text("Reset")
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial)
                                .foregroundStyle(Color.primary)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            onSave(notesText)
                            isExpanded = false
                        }) {
                            Text("Apply")
                                .font(.body)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.brewPrimary, Color.brewAccent]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.primary.opacity(0.6) : Color.white)
                                .cornerRadius(12)
                                .shadow(color: notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.clear : Color.brewPrimary.opacity(0.3), 
                                        radius: notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 8, 
                                        x: 0, 
                                        y: notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.brewSecondary.opacity(0.3))
            }
        }
        .onAppear {
            loadDefaults()
        }
    }
    
    private func loadDefaults() {
        notesText = customNotes ?? method.brewNotes
    }
}

// MARK: - Theme Button
struct ThemeButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: theme.icon)
                    .font(.title2)
                    .fontWeight(.medium)
                    .accessibilityHidden(true)
                Text(theme.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 60)
            .padding(.vertical, 16)
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
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.375) : Color.black.opacity(0.06), 
                    radius: isSelected ? 12 : 3, x: 0, y: isSelected ? 6 : 1.5)
            .shadow(color: isSelected ? Color.brewPrimary.opacity(0.225) : Color.clear, 
                    radius: isSelected ? 6 : 0, x: 0, y: isSelected ? 3 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.rawValue) theme")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Currently selected theme" : "Tap to select \(theme.rawValue) theme")
    }
}

#Preview {
    CustomizationView()
}
