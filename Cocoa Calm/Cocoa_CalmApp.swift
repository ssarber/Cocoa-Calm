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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @StateObject private var subscriptionManager = SubscriptionManager()

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
        WindowGroup(makeContent: {
            if hasCompletedOnboarding {
                HomeView()
                    .environmentObject(subscriptionManager)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environmentObject(subscriptionManager)
            }
        })
        .modelContainer(sharedModelContainer)
    }
}
