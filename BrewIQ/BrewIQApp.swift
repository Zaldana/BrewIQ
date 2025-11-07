//
//  BrewIQApp.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI
import SwiftData

@main
struct BrewIQApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CustomBrewMethod.self,
            UserPreferences.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If migration fails, try to reset the data store
            print("ModelContainer creation failed, attempting to reset data store: \(error)")
            
            // Get the default store URL and delete it
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            
            // Try again with fresh container
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
