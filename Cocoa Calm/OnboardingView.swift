
import SwiftUI

struct OnboardingStepView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor) // Use accent color

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer() // Pushes content to center
        }
        .padding(40) // Add more padding around the content
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentTab = 0

    // Define onboarding steps
    let onboardingSteps = [
        OnboardingStepContent(imageName: "sparkles", title: "Welcome to Cocoa Calm", description: "Your companion for finding moments of peace and managing anxiety with simple, calming exercises."),
        OnboardingStepContent(imageName: "figure.mind.and.body", title: "Discover Quick Relief", description: "Access breathing exercises, mindful guides like the Hot Chocolate Ritual, and meditation timers designed to help you reset and relax."),
        OnboardingStepContent(imageName: "checkmark.circle.fill", title: "Ready to Begin?", description: "Explore Cocoa Calm and start your journey towards a more mindful and peaceful state.")
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                ForEach(0..<onboardingSteps.count, id: \.self) { index in
                    OnboardingStepView(
                        imageName: onboardingSteps[index].imageName,
                        title: onboardingSteps[index].title,
                        description: onboardingSteps[index].description
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .padding(.bottom, 20) // Space for button

            if currentTab == onboardingSteps.count - 1 {
                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.accentColor) // Use accent color
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.bottom, 30)
            } else {
                // Placeholder for button height consistency
                Button {} label: { Text("").padding().frame(maxWidth: 200) }
                .padding(.bottom, 30)
                .hidden() // Keep space but hide
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea()) // Standard window background
    }
}

// Helper struct for content
struct OnboardingStepContent {
    let imageName: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
