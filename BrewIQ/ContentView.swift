//
//  ContentView.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    
    private var userPrefs: UserPreferences {
        if let prefs = preferences.first {
            return prefs
        } else {
            let newPrefs = UserPreferences()
            modelContext.insert(newPrefs)
            return newPrefs
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch userPrefs.theme {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
    
    var body: some View {
        SplashView()
            .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
}
