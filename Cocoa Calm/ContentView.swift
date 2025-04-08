//
//  ContentView.swift
//  Cocoa Calm
//
//  Created by Stan Sarber on 3/30/25.
//

import SwiftUI
import SwiftData

enum NavigationTarget: Identifiable {
    case hotChocolate
    // Add other cases if needed, e.g., .quickMeditation
    
    var id: NavigationTarget { self } // Make identifiable for NavigationLink tag/selection
}

// Placeholder for the SOS quick actions view that will pop up
struct SOSView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet

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
                    // TODO: Implement 1-min Guided Breathing
                    print("Guided Breathing action tapped")
                    dismiss()
                } label: {
                    Label("Breathe (1 min Guided)", systemImage: "wind")
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
                     // TODO: Navigate to Hot Chocolate Guide
                    print("Hot Chocolate guide action tapped")
                    HotChocolateGuideView()
                    dismiss()
                } label: {
                    Label("Mindful Sip Prep", systemImage: "cup.and.saucer")
                     .frame(maxWidth: .infinity)
                }
              
//                  NavigationLink {
//                      // Destination: The view to navigate to
//                      HotChocolateGuideView()
//                  } label: {
//                      // Label: The visual content of the button (what used to be inside QuickActionButton)
//                      VStack {
//                          Image(systemName: "cup.and.saucer.fill")
//                              .font(.title2)
//                              .foregroundColor(.primary.opacity(0.8)) // Ensure text/icon color is visible
//                          Text("Hot Chocolate")
//                              .font(.caption)
//                              .foregroundColor(.secondary) // Ensure text/icon color is visible
//                      }
//                      .padding()
//                      .frame(maxWidth: .infinity) // Makes the button take up available horizontal space
//                      .background(.regularMaterial) // The background style
//                      .cornerRadius(10)
//                  }
//                  .buttonStyle(.plain)
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }


// The main Home View
struct HomeView: View {
    // State to control the presentation of the SOS modal sheet
    @State private var showingSOSSheet = false
    // State for the daily quote (could be fetched or randomized)
    @State private var dailyQuote = "Take a deep breath, you've got this."
  
    @State private var navigationTarget: NavigationTarget? = nil

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
        NavigationView { // Provides a title bar area if needed
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea() // Extend gradient to screen edges

                ScrollView { // Allows content to scroll if it exceeds screen height
                    VStack(alignment: .leading, spacing: 30) {
                      NavigationLink(destination: destinationView(for: navigationTarget), // Destination view
                         tag: navigationTarget ?? .hotChocolate, // Use optional tag matching
                         selection: $navigationTarget // Bind to the state variable
                      ) {
                        EmptyView() // Hidden label
                      }

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
                              .foregroundColor(.white) // White text usually contrasts well
                              .background(Color.indigo.opacity(0.8)) // CHANGED COLOR HERE
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
                                QuickActionButton(title: "Meditate", icon: "figure.mind.and.body") {
                                    // TODO: Navigate to Meditation List View
                                    print("Navigate to Meditate")
                                }

                              NavigationLink {
                                  // Destination: The view to navigate to
                                  HotChocolateGuideView()
                              } label: {
                                  // Label: The visual content of the button (what used to be inside QuickActionButton)
                                  VStack {
                                      Image(systemName: "cup.and.saucer.fill")
                                          .font(.title2)
                                          .foregroundColor(.primary.opacity(0.8)) // Ensure text/icon color is visible
                                      Text("Hot Chocolate")
                                          .font(.caption)
                                          .foregroundColor(.secondary) // Ensure text/icon color is visible
                                  }
                                  .padding()
                                  .frame(maxWidth: .infinity) // Makes the button take up available horizontal space
                                  .background(.regularMaterial) // The background style
                                  .cornerRadius(10)
                              }
                              .buttonStyle(.plain)
                            }

                             HStack(spacing: 15) {
                                QuickActionButton(title: "Log Entry", icon: "pencil.and.list.clipboard") {
                                    // TODO: Navigate/present Journal Add View
                                    print("Navigate to Log Entry")
                                }
                                // Add more quick actions if needed
                                Spacer() // Pushes buttons left if fewer than fit
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
                                .background(.ultraThinMaterial) // Subtle background
                                .cornerRadius(10)
                        }
                        .padding(.top) // Add space above the quote

                        Spacer() // Pushes content towards the top

                    }
                    .padding() // Padding for the main VStack content
                }
            }
             // Use .navigationTitle("Cocoa Calm") or similar if you want a title
             // Or hide the navigation bar if you prefer a cleaner look
            .navigationBarHidden(true) // Example: Hide the navigation bar
            .sheet(isPresented: $showingSOSSheet) {
                SOSView() // Present the SOSView when the button is tapped
            }
            .onAppear {
                // Select a random quote when the view appears
                dailyQuote = quotes.randomElement() ?? "Take a gentle moment for yourself."
            }
        }
        // Apply styling appropriate for a NavigationView if you decide to show the bar
        // .navigationViewStyle(.stack) // Recommended for iOS 16+ if needed
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
