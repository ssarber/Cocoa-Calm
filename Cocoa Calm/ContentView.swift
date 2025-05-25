// MARK: - HomeView.swift
// Includes SOSView, QuickActionButton

import SwiftUI

// Placeholder for the SOS quick actions view that will pop up
struct SOSView: View {
  @Environment(\.dismiss) var dismiss // To close the sheet
  
  // Add binding for showing BreatheView and HotChocolateGuideView
  @Binding var showingBreatheView: Bool
  @Binding var showingHotChocolateGuideView: Bool
  
  var body: some View {
    NavigationView { // Gives us a title bar and potentially a done button
      VStack(spacing: 20) {
        Text("Take a Moment")
          .font(.largeTitle)
          .padding(.top)
        
        Text("Choose a quick way to reset:")
          .font(.headline)
          .foregroundStyle(.secondary)
        
        Button {
          // SET STATE & DISMISS SOS
          showingBreatheView = true // Signal HomeView to show BreatheView
          dismiss() // Close the SOS sheet
        } label: {
          Label("Breathe (3 inhales, 3 exhales)", systemImage: "wind")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue.opacity(0.7)) // Calmer blue
        
        Button {
          // TODO: Implement Quick Grounding Exercise
          print("Quick Grounding action tapped")
          dismiss()
        } label: {
          Label("Quick Grounding", systemImage: "hand.draw")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green.opacity(0.7)) // Calmer green
        
        Button {
          // SET STATE & DISMISS
          showingHotChocolateGuideView = true // Set the state in HomeView
          dismiss() // Close the sheet
        } label: {
          Label("Mindful Sip Prep", systemImage: "cup.and.saucer")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.brown.opacity(0.7)) // Warm brown
        
        Spacer()
      }
      .padding()
      .navigationTitle("Quick Relief")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
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

// The main Home View
struct HomeView: View {
  // State to control the presentation of the SOS modal sheet
  @State private var showingSOSSheet = false
  // State to control presentation of the BreatheView modal sheet
  @State private var showingBreatheView = false
  // State for the daily quote (could be fetched or randomized)
  @State private var dailyQuote = "Take a deep breath, you've got this."
  
  // State variables to control modal presentations
  @State private var showingMeditateView = false
  @State private var showingHotChocolateGuideView = false
  @State private var showingHotChocolateAudioView = false
  
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
    // Ensure HomeView is wrapped in NavigationView for navigation styling
    NavigationView {
      ZStack {
        // Reverted Background Gradient
        LinearGradient(
          gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea() // Extend gradient to screen edges
        
        ScrollView { // Allows content to scroll if it exceeds screen height
          VStack(alignment: .leading, spacing: 30) {
            
            // 1. Greeting
            Text("Welcome")
              .font(.system(size: 34, weight: .bold))
              .padding(.top) // Add padding from the top navigation bar area
            
            // 2. "Feeling Anxious?" Button
            Button {
              showingSOSSheet = true // Trigger the modal sheet
            } label: {
              Text("Feeling Anxious?")
                .font(.headline)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity) // Make button wide
                .foregroundColor(.white)
                // Reverted background color
                .background(Color.teal.opacity(0.8)) // Calm Teal
                .cornerRadius(12)
                .shadow(radius: 5)
            }
            .padding(.horizontal) // Keep button within screen bounds
            
            
            // 3. Quick Actions Section
            VStack(alignment: .leading, spacing: 15) {
              Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)
              
              HStack(spacing: 15) {
                // --- Changed to button with modal presentation ---
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
                    .frame(maxWidth: .infinity) // Distribute space if in HStack
                    .background(.regularMaterial) // Subtle background like control center
                    .cornerRadius(10)
                }
                
                // *** Changed to button with modal presentation ***
                Button {
                  showingHotChocolateGuideView = true
                } label: {
                  // Label: The visual content of the button
                  VStack {
                    Image(systemName: "cup.and.saucer.fill")
                      .font(.title2)
                      .foregroundColor(.primary.opacity(0.8))
                    Text("Hot Chocolate")
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }
                  .padding()
                  .frame(maxWidth: .infinity) // Distribute space if in HStack
                  .background(.regularMaterial) // Subtle background like control center
                  .cornerRadius(10)
                }
                
                // --- Changed to button with modal presentation ---
                Button {
                    showingHotChocolateAudioView = true
                } label: {
                    VStack {
                        Image(systemName: "headphones.circle.fill") // Different icon
                            .font(.title2)
                            .foregroundColor(.primary.opacity(0.8))
                        Text("HC Audio") // Shorter text
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Distribute space if in HStack
                    .background(.regularMaterial) // Subtle background like control center
                    .cornerRadius(10)
                }
                
              } // End HStack
              
              HStack(spacing: 15) {
                QuickActionButton(title: "Log Entry", icon: "pencil.and.list.clipboard") {
                  // TODO: Navigate/present Journal Add View
                  print("Navigate to Log Entry")
                }
                // Add more quick actions if needed
                Spacer() // Pushes buttons left if fewer than fit
              } // End HStack
            } // End VStack Quick Actions
            
            
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
                .background(.ultraThinMaterial) // Subtle background
                .cornerRadius(10)
            }
            .padding(.top) // Add space above the quote
            
            Spacer() // Pushes content towards the top
            
          } // End Main VStack
          .padding() // Padding for the main VStack content
        } // End ScrollView
      } // End ZStack
      .navigationBarHidden(true) // Example: Hide the navigation bar
      .sheet(isPresented: $showingSOSSheet) {
        // Pass the bindings to SOSView
        SOSView(showingBreatheView: $showingBreatheView, showingHotChocolateGuideView: $showingHotChocolateGuideView)
      }
      // Add sheet modifiers for each view
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
      }
      .onAppear {
        // Select a random quote when the view appears
        dailyQuote = quotes.randomElement() ?? "Take a gentle moment for yourself."
      }
    } // End NavigationView
    // Apply styling appropriate for a NavigationView if you decide to show the bar
    // .navigationViewStyle(.stack) // Recommended for iOS 16+ if needed
  }
}

// Helper View for Quick Action Buttons (that perform actions, not navigate directly)
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
      .frame(maxWidth: .infinity) // Distribute space if in HStack
      .background(.regularMaterial) // Subtle background like control center
      .cornerRadius(10)
    }
  }
}

// Preview Provider
#Preview {
  // Wrap in TabView to simulate real usage context (optional but good)
  TabView {
    HomeView()
      .tabItem {
        Label("Home", systemImage: "house.fill")
      }
    // Add other placeholder tabs if you like
    Text("Relief Tools Tab")
      .tabItem {
        Label("Tools", systemImage: "wand.and.stars")
      }
  }
}
