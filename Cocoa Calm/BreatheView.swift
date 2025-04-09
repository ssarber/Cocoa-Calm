// MARK: - BreatheView.swift

import SwiftUI

struct BreatheView: View {
    @Environment(\.dismiss) var dismiss // For the Done button

    var body: some View {
        NavigationView { // Provides a title bar and standard controls
            VStack(spacing: 40) { // Increased spacing for visual separation
                Spacer() // Push content towards the center

                Text("Focus on Your Breath")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Take 3 sharp inhalations through your nose, filling your belly.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Then, release with 3 strong, audible exhalations through your mouth.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer() // Push content towards the center
                Spacer() // Add more space below
            }
            .padding()
            .navigationTitle("Guided Breathing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // Dismiss the sheet
                    }
                }
            }
        }
    }
}

#Preview {
    BreatheView()
} 