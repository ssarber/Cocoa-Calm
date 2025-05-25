//
//  Cocoa_CalmApp.swift
//  Cocoa Calm
//
//  Created by Stan Sarber on 3/30/25.
//

import SwiftUI
import SwiftData

@main
struct Cocoa_CalmApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false // Tracks onboarding status

    var sharedModelContainer: ModelContainer = {
        // ... (your existing model container setup)
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding) // Show onboarding if not completed
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
