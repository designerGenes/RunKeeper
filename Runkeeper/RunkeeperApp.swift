//
//  RunkeeperApp.swift
//  Runkeeper
//
//  Created by Jaden Nation on 6/23/24.
//

import SwiftUI
import SwiftData

@main
struct RunkeeperApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Run.self, RunManager.self])
    }
}
