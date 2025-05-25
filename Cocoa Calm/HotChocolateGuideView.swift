//
//  HotChocolateView.swift
//  Cocoa Calm
//
//  Created by Stan Sarber on 4/3/25.
//

import SwiftUI

struct HotChocolateGuideView: View {
    @Environment(\.dismiss) var dismiss // For modal dismissal
    
    var body: some View {
        NavigationView { // Wrap in NavigationView for toolbar
            ZStack {
            // Background Gradient - reverted to slightly warmer variation
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.brown.opacity(0.15)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Extend gradient to screen edges

            ScrollView {
                VStack(alignment: .leading, spacing: 25) {

                    // 1. Header Section with Icon
                    HStack(spacing: 15) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.largeTitle)
                            .foregroundColor(.brown.opacity(0.8))

                        Text("Mindful Hot Chocolate")
                            .font(.system(size: 28, weight: .bold)) // Slightly smaller than HomeView's main title
                    }
                    .padding(.bottom, 10)

                    // 2. Introductory Mindfulness Prompt
                    Text("Pause and engage your senses. This simple ritual is an opportunity to be present and find comfort.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 15)

                    // 3. Recipe Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Simple Comfort Recipe")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, 5)

                        // Step 1
                        RecipeStepView(
                            stepNumber: 1,
                            instruction: "Pour half a cup of almond milk (or your favourite milk) into a mug.",
                            mindfulPrompt: "Notice the sound as it pours, the colour and texture."
                        )

                        // Step 2
                        RecipeStepView(
                            stepNumber: 2,
                            instruction: "Add a *lot* of cocoa powder – as much as feels comforting!",
                            mindfulPrompt: "Observe the rich powder, its fine texture, its deep aroma."
                        )

                        // Step 3
                        RecipeStepView(
                            stepNumber: 3,
                            instruction: "Mix gently until smooth.",
                            mindfulPrompt: "Focus on the swirling motion, the gradual blending of colours."
                        )

                        // Step 4 (Heating - common step)
                        RecipeStepView(
                            stepNumber: 4,
                            instruction: "Warm gently (microwave or stovetop) until it reaches a comforting temperature.",
                            mindfulPrompt: "Feel the growing warmth in the mug or saucepan handle."
                        )

                        // Step 5 (Savoring)
                         RecipeStepView(
                            stepNumber: 5,
                            instruction: "Find a quiet spot. Hold the warm mug.",
                            mindfulPrompt: "Breathe in the rich scent. Take slow, mindful sips. Enjoy."
                        )
                    }

                    // 4. Optional: Log Button (Placeholder for future)
                     Button {
                         // TODO: Implement logging to Journal
                         print("Log Hot Chocolate Activity tapped")
                     } label: {
                         Label("Log this Ritual", systemImage: "checkmark.circle.fill")
                             .padding(.vertical, 10)
                             .frame(maxWidth: .infinity)
                     }
                     .buttonStyle(.bordered) // Use bordered style for less emphasis than main SOS button
                     .tint(.brown.opacity(0.8)) // Consistent warm tint
                     .padding(.top, 20)


                    Spacer() // Pushes content up
                }
                .padding() // Padding for the main VStack content
            }
        }
        // Setting the navigation bar title - this assumes the parent view (HomeView's NavLink)
        // doesn't override it forcefully. Adjust as needed.
        .navigationTitle("Hot Chocolate Ritual")
        .navigationBarTitleDisplayMode(.inline) // Keeps title neat
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss() // Dismiss the modal
                }
            }
        }
        }
    }
}

// Helper View for consistent step formatting
struct RecipeStepView: View {
    let stepNumber: Int
    let instruction: String
    let mindfulPrompt: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("\(stepNumber)")
                .font(.title3)
                .bold()
                .foregroundColor(.brown) // Accent color
                .frame(width: 25, alignment: .trailing) // Align numbers

            VStack(alignment: .leading, spacing: 5) {
                Text(instruction)
                    .font(.headline)
                    .foregroundStyle(.primary.opacity(0.9)) // Main text

                Text(mindfulPrompt)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary) // Secondary text for prompt
            }
        }
    }
}


// Preview Provider
#Preview {
    // Preview as a modal sheet
    HotChocolateGuideView()
}
