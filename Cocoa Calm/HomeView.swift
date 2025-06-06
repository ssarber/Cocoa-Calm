//
//  HomeView.swift
//  Cocoa Calm
//
//  Main home view with premium integration
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var contentManager = ContentManager()
    // State to control the presentation of modal sheets
    @State private var showingSOSSheet = false
    @State private var showingBreatheView = false
    @State private var showingMeditateView = false
    @State private var showingHotChocolateGuideView = false
    @State private var showingHotChocolateAudioView = false
    @State private var showingMeditationLibrary = false
    @State private var showingProgressView = false
    @State private var showingEnhancedTimer = false
    @State private var dailyQuote = "Take a deep breath, you've got this."
    
    // Example quotes - you could load these from elsewhere
    let quotes = [
        "Just this breath. Just this moment.",
        "Be kind to your mind.",
        "You are stronger than your anxiety.",
        "Pause, breathe, proceed.",
        "Find calm in the chaos.",
        "Warmth and comfort are near."
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // 1. Greeting with Subscription Status
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome")
                                    .font(.system(size: 34, weight: .bold))
                                
                                if subscriptionManager.canAccessPremiumContent() {
                                    Text("Premium Member")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(.blue.opacity(0.1))
                                        .cornerRadius(8)
                                } else {
                                    Text("Free Plan")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(.orange.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            
                            Spacer()
                            
                            if !subscriptionManager.canAccessPremiumContent() {
                                Button("Upgrade") {
                                    showingMeditationLibrary = true
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.top)
                        
                        // 2. "Feeling Anxious?" Button
                        Button {
                            showingSOSSheet = true
                        } label: {
                            Text("Feeling Anxious?")
                                .font(.headline)
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(Color.teal.opacity(0.8))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        
                        // 3. Quick Actions Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quick Actions")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 15) {
                                Button {
                                    showingMeditateView = true
                                } label: {
                                    VStack {
                                        Image(systemName: "figure.mind.and.body")
                                            .font(.title2)
                                            .foregroundColor(.primary.opacity(0.8))
                                        Text("Meditate")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.regularMaterial)
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    showingHotChocolateGuideView = true
                                } label: {
                                    VStack {
                                        Image(systemName: "cup.and.saucer.fill")
                                            .font(.title2)
                                            .foregroundColor(.primary.opacity(0.8))
                                        Text("Hot Chocolate")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.regularMaterial)
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    showingHotChocolateAudioView = true
                                } label: {
                                    VStack {
                                        Image(systemName: "headphones.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.primary.opacity(0.8))
                                        Text("Audio Guide")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if !subscriptionManager.canAccessPremiumContent() {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.regularMaterial)
                                    .cornerRadius(10)
                                }
                            }
                            
                            HStack(spacing: 15) {
                                Button {
                                    showingMeditationLibrary = true
                                } label: {
                                    VStack {
                                        Image(systemName: "book.fill")
                                            .font(.title2)
                                            .foregroundColor(.primary.opacity(0.8))
                                        Text("Library")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.regularMaterial)
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    if subscriptionManager.canAccessPremiumContent() {
                                        showingProgressView = true
                                    } else {
                                        showingMeditationLibrary = true
                                    }
                                } label: {
                                    VStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .font(.title2)
                                            .foregroundColor(.primary.opacity(0.8))
                                        Text("Progress")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if !subscriptionManager.canAccessPremiumContent() {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.regularMaterial)
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    if subscriptionManager.canAccessPremiumContent() {
                                        showingEnhancedTimer = true
                                    } else {
                                        showingMeditationLibrary = true
                                    }
                                } label: {
                                    VStack {
                                        Image(systemName: "timer.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.primary.opacity(0.8))
                                        Text("Timer+")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if !subscriptionManager.canAccessPremiumContent() {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.regularMaterial)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        // 4. Daily Quote / Gentle Reminder
                        VStack(alignment: .center) {
                            Text("A Gentle Thought")
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding(.bottom, 5)
                            
                            Text(dailyQuote)
                                .font(.body)
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSOSSheet) {
                SOSView(showingBreatheView: $showingBreatheView, showingHotChocolateGuideView: $showingHotChocolateGuideView)
            }
            .sheet(isPresented: $showingBreatheView) {
                BreatheView()
            }
            .sheet(isPresented: $showingMeditateView) {
                MeditateView()
            }
            .sheet(isPresented: $showingHotChocolateGuideView) {
                HotChocolateGuideView()
            }
            .sheet(isPresented: $showingHotChocolateAudioView) {
                HotChocolateGuideAudioView()
                    .environmentObject(subscriptionManager)
            }
            .sheet(isPresented: $showingMeditationLibrary) {
                MeditationLibraryView()
            }
            .sheet(isPresented: $showingProgressView) {
                UserProgressView()
                    .environmentObject(subscriptionManager)
            }
            .sheet(isPresented: $showingEnhancedTimer) {
                EnhancedMeditationTimer()
                    .environmentObject(subscriptionManager)
            }
            .onAppear {
                dailyQuote = quotes.randomElement() ?? "Take a gentle moment for yourself."
            }
        }
    }
}

// Helper View for Quick Action Buttons
struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primary.opacity(0.8))
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .cornerRadius(10)
        }
    }
}

// Placeholder for the SOS quick actions view
struct SOSView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var showingBreatheView: Bool
    @Binding var showingHotChocolateGuideView: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Take a Moment")
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("Choose a quick way to reset:")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Button {
                    showingBreatheView = true
                    dismiss()
                } label: {
                    Label("Breathe (3 inhales, 3 exhales)", systemImage: "wind")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue.opacity(0.7))
                
                Button {
                    print("Quick Grounding action tapped")
                    dismiss()
                } label: {
                    Label("Quick Grounding", systemImage: "hand.draw")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green.opacity(0.7))
                
                Button {
                    showingHotChocolateGuideView = true
                    dismiss()
                } label: {
                    Label("Mindful Sip Prep", systemImage: "cup.and.saucer")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown.opacity(0.7))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Quick Relief")
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
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SubscriptionManager())
    }
}
