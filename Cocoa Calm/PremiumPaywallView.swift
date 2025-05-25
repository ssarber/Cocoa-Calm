//
//  PremiumPaywallView.swift
//  Cocoa Calm
//
//  Premium subscription paywall with 7-day free trial
//

import SwiftUI
import StoreKit

struct PremiumPaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    @State private var animateFeatures = false
    
    let contentTitle: String
    
    init(contentTitle: String = "Premium Content") {
        self.contentTitle = contentTitle
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.2),
                        Color.indigo.opacity(0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Premium Features
                        premiumFeaturesSection
                        
                        // Pricing Plans
                        pricingPlansSection
                        
                        // Free Trial CTA
                        freeTrialSection
                        
                        // Social Proof
                        socialProofSection
                        
                        // Legal Links
                        legalLinksSection
                        
                        Spacer(minLength: 100) // Space for bottom CTA
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Bottom CTA Button
                VStack {
                    Spacer()
                    ctaButtonSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34) // Safe area
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Restore") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateFeatures = true
            }
        }
        .sheet(isPresented: $showingTerms) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyPolicyView()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Icon or Logo
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(animateFeatures ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateFeatures)
            
            VStack(spacing: 8) {
                Text("Unlock \(contentTitle)")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Start your 7-day free trial and access our complete library of guided meditations, breathing exercises, and mindful rituals.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
    }
    
    // MARK: - Premium Features Section
    
    private var premiumFeaturesSection: some View {
        VStack(spacing: 20) {
            Text("What's Included")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                FeatureCard(
                    icon: "brain.head.profile",
                    title: "50+ Guided Meditations",
                    description: "Expert-led sessions for anxiety, sleep, and focus",
                    delay: 0.1
                )
                
                FeatureCard(
                    icon: "heart.circle.fill",
                    title: "Anxiety Relief Programs",
                    description: "Specialized series for managing stress and worry",
                    delay: 0.2
                )
                
                FeatureCard(
                    icon: "moon.circle.fill",
                    title: "Sleep & Rest Content",
                    description: "Wind down with bedtime stories and sleep meditations",
                    delay: 0.3
                )
                
                FeatureCard(
                    icon: "cup.and.saucer.fill",
                    title: "Mindful Rituals",
                    description: "Turn daily activities into meditation practices",
                    delay: 0.4
                )
                
                FeatureCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress Tracking",
                    description: "Monitor your wellness journey with detailed insights",
                    delay: 0.5
                )
                
                FeatureCard(
                    icon: "sparkles",
                    title: "New Content Weekly",
                    description: "Fresh meditations and seasonal programs added regularly",
                    delay: 0.6
                )
            }
        }
        .opacity(animateFeatures ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateFeatures)
    }
    
    // MARK: - Pricing Plans Section
    
    private var pricingPlansSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                    PricingPlanCard(
                        plan: plan,
                        isSelected: selectedPlan == plan,
                        onTap: {
                            selectedPlan = plan
                        }
                    )
                }
            }
        }
        .opacity(animateFeatures ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.8).delay(0.4), value: animateFeatures)
    }
    
    // MARK: - Free Trial Section
    
    private var freeTrialSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.green)
                Text("7-Day Free Trial")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("Try everything free for a week. Cancel anytime before the trial ends and you won't be charged.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .opacity(animateFeatures ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.8).delay(0.6), value: animateFeatures)
    }
    
    // MARK: - Social Proof Section
    
    private var socialProofSection: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Text("4.8")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("• 10,000+ reviews")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\"This app has genuinely helped me manage my anxiety. The guided meditations are exactly what I needed.\"")
                .font(.subheadline)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("- Sarah M., Premium Member")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .opacity(animateFeatures ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.8).delay(0.8), value: animateFeatures)
    }
    
    // MARK: - CTA Button Section
    
    private var ctaButtonSection: some View {
        VStack(spacing: 12) {
            Button {
                startFreeTrial()
            } label: {
                VStack(spacing: 4) {
                    Text("Start Free Trial")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Then \(selectedPlan.price)/\(selectedPlan.displayName.lowercased())")
                        .font(.caption)
                        .opacity(0.9)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(subscriptionManager.isLoading)
            .opacity(subscriptionManager.isLoading ? 0.6 : 1.0)
            
            if subscriptionManager.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .background(.regularMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Legal Links Section
    
    private var legalLinksSection: some View {
        HStack(spacing: 24) {
            Button("Terms of Service") {
                showingTerms = true
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button("Privacy Policy") {
                showingPrivacy = true
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Actions
    
    private func startFreeTrial() {
        // If we have products loaded, purchase the selected plan
        if let product = subscriptionManager.availableProducts.first(where: { $0.id == selectedPlan.rawValue }) {
            Task {
                do {
                    try await subscriptionManager.purchase(product)
                    dismiss()
                } catch {
                    // Handle error
                    print("Purchase failed: \(error)")
                }
            }
        } else {
            // Fallback: start trial mode for development/testing
            subscriptionManager.startFreeTrial()
            dismiss()
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(height: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .scaleEffect(animate ? 1.0 : 0.9)
        .opacity(animate ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                animate = true
            }
        }
    }
}

// MARK: - Pricing Plan Card

struct PricingPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if plan == .annual {
                            Text("POPULAR")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    
                    Text(plan.price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let savings = plan.savings {
                        Text(savings)
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(isSelected ? .blue.opacity(0.1) : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .blue : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Terms and Privacy Views (Placeholder)

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Terms of Service content would go here...")
                    .padding()
            }
            .navigationTitle("Terms of Service")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Privacy Policy content would go here...")
                    .padding()
            }
            .navigationTitle("Privacy Policy")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct PremiumPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumPaywallView(contentTitle: "Premium Meditation Library")
    }
}