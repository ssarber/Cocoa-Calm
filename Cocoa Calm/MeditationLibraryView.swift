//
//  MeditationLibraryView.swift
//  Cocoa Calm
//
//  Premium meditation library showcasing subscription content
//

import SwiftUI

struct MeditationLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: ContentItem.ContentCategory = .meditation
    @State private var showingPaywall = false
    @State private var selectedContent: ContentItem?
    
    // Mock subscription state for demo - in real app this would come from SubscriptionManager
    @State private var hasSubscription = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with subscription status
                subscriptionStatusHeader
                
                // Category tabs
                categoryTabs
                
                // Content library
                contentLibraryView
            }
            .navigationTitle("Meditation Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            // Use our new premium paywall
            premiumPaywallView
        }
        .sheet(item: $selectedContent) { content in
            ContentDetailView(content: content, hasSubscription: hasSubscription)
        }
    }
    
    // MARK: - Subscription Status Header
    
    private var subscriptionStatusHeader: some View {
        VStack(spacing: 12) {
            if hasSubscription {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Premium Active")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("Full Access")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
                .padding()
                .background(.green.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "lock.circle.fill")
                            .foregroundColor(.orange)
                        Text("Free Plan")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("Upgrade") {
                            showingPaywall = true
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Text("Unlock 50+ guided meditations, sleep stories, and mindful rituals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Category Tabs
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ContentItem.ContentCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: {
                            selectedCategory = category
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Content Library View
    
    private var contentLibraryView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(getContentForCategory(selectedCategory)) { content in
                    ContentRow(
                        content: content,
                        hasAccess: hasSubscription || !content.isPremium,
                        onTap: {
                            if hasSubscription || !content.isPremium {
                                selectedContent = content
                            } else {
                                showingPaywall = true
                            }
                        }
                    )
                }
                
                // Show upgrade prompt at bottom for free users
                if !hasSubscription {
                    upgradePromptView
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Upgrade Prompt
    
    private var upgradePromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Unlock Your Full Potential")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Access our complete library of guided meditations, sleep stories, and anxiety relief programs.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingPaywall = true
            } label: {
                Text("Start 7-Day Free Trial")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            
            Text("Then $4.99/week • Cancel anytime")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Premium Paywall
    
    private var premiumPaywallView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("Unlock Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Start your 7-day free trial")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Benefits
            VStack(spacing: 16) {
                BenefitRow(icon: "brain.head.profile", title: "50+ Guided Meditations", description: "Expert-led sessions for every situation")
                BenefitRow(icon: "moon.stars.fill", title: "Sleep & Rest Content", description: "Bedtime stories and deep sleep meditations")
                BenefitRow(icon: "heart.circle.fill", title: "Anxiety Relief Programs", description: "Specialized series for stress management")
                BenefitRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", description: "Monitor your wellness journey")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // CTA
            VStack(spacing: 12) {
                Button {
                    // Mock upgrade - in real app this would trigger StoreKit
                    hasSubscription = true
                    showingPaywall = false
                } label: {
                    VStack(spacing: 4) {
                        Text("Start Free Trial")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Then $4.99/week")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue)
                    .cornerRadius(12)
                }
                
                Button("Not Now") {
                    showingPaywall = false
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(.regularMaterial)
    }
    
    // MARK: - Helper Functions
    
    private func getContentForCategory(_ category: ContentItem.ContentCategory) -> [ContentItem] {
        // Mock content based on our PRD
        switch category {
        case .crisis:
            return [
                ContentItem(
                    id: "crisis_sos",
                    title: "SOS Breathing",
                    description: "Quick 3-4-5 breathing for immediate relief",
                    category: .crisis,
                    subcategory: "Emergency",
                    duration: 180,
                    isPremium: false,
                    audioFileName: "sos_breathing.mp3",
                    instructionPhases: nil,
                    tags: ["crisis", "breathing"],
                    difficulty: .beginner,
                    createdDate: Date(),
                    updatedDate: Date()
                ),
                ContentItem(
                    id: "crisis_grounding",
                    title: "5-4-3-2-1 Grounding",
                    description: "Sensory grounding for panic attacks",
                    category: .crisis,
                    subcategory: "Emergency",
                    duration: 300,
                    isPremium: false,
                    audioFileName: "grounding.mp3",
                    instructionPhases: nil,
                    tags: ["crisis", "grounding"],
                    difficulty: .beginner,
                    createdDate: Date(),
                    updatedDate: Date()
                )
            ]
            
        case .meditation:
            return [
                ContentItem(
                    id: "beginner_1",
                    title: "Introduction to Meditation",
                    description: "Your first step into mindfulness practice",
                    category: .meditation,
                    subcategory: "Beginner Series",
                    duration: 300,
                    isPremium: true,
                    audioFileName: "beginner_1.mp3",
                    instructionPhases: nil,
                    tags: ["meditation", "beginner"],
                    difficulty: .beginner,
                    createdDate: Date(),
                    updatedDate: Date()
                ),
                ContentItem(
                    id: "anxiety_1",
                    title: "Understanding Anxiety",
                    description: "Learn how meditation helps with anxiety",
                    category: .meditation,
                    subcategory: "Anxiety Management",
                    duration: 480,
                    isPremium: true,
                    audioFileName: "anxiety_1.mp3",
                    instructionPhases: nil,
                    tags: ["meditation", "anxiety"],
                    difficulty: .intermediate,
                    createdDate: Date(),
                    updatedDate: Date()
                ),
                ContentItem(
                    id: "sleep_1",
                    title: "Evening Wind Down",
                    description: "Prepare your mind and body for rest",
                    category: .meditation,
                    subcategory: "Sleep & Rest",
                    duration: 900,
                    isPremium: true,
                    audioFileName: "sleep_1.mp3",
                    instructionPhases: nil,
                    tags: ["meditation", "sleep"],
                    difficulty: .beginner,
                    createdDate: Date(),
                    updatedDate: Date()
                )
            ]
            
        case .ritual:
            return [
                ContentItem(
                    id: "ritual_chocolate",
                    title: "Mindful Hot Chocolate",
                    description: "Turn your favorite drink into meditation",
                    category: .ritual,
                    subcategory: "Warm Drinks",
                    duration: 1200,
                    isPremium: true,
                    audioFileName: "hot_chocolate_guide.mp3",
                    instructionPhases: nil,
                    tags: ["ritual", "mindfulness"],
                    difficulty: .beginner,
                    createdDate: Date(),
                    updatedDate: Date()
                )
            ]
            
        default:
            return []
        }
    }
}

// MARK: - Supporting Views

struct CategoryTab: View {
    let category: ContentItem.ContentCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? .blue : .clear)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentRow: View {
    let content: ContentItem
    let hasAccess: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Duration and category indicator
                VStack(spacing: 4) {
                    Text("\(Int(content.duration / 60))")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("MIN")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(content.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if !hasAccess {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(content.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(content.subcategory ?? "")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                        
                        Text(content.difficulty.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.gray.opacity(0.1))
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(hasAccess ? .clear : .gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(hasAccess ? 1.0 : 0.7)
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ContentDetailView: View {
    let content: ContentItem
    let hasSubscription: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(content.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(content.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(label: "Duration", value: "\(Int(content.duration / 60)) minutes")
                        DetailRow(label: "Category", value: content.category.rawValue)
                        DetailRow(label: "Difficulty", value: content.difficulty.rawValue)
                        if let subcategory = content.subcategory {
                            DetailRow(label: "Series", value: subcategory)
                        }
                    }
                    
                    // Play button
                    if hasSubscription || !content.isPremium {
                        Button {
                            // Would navigate to actual player
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Start Session")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.blue)
                            .cornerRadius(12)
                        }
                    } else {
                        Button {
                            // Would show paywall
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Unlock with Premium")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.orange)
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Session Details")
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

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

struct MeditationLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        MeditationLibraryView()
    }
}