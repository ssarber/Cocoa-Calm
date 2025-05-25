// MARK: - BreatheView.swift

import SwiftUI
import AVFoundation // Import for audio playback

struct BreatheView: View {
    @Environment(\.dismiss) var dismiss // For the Done button

    // State for animation
    @State private var scale: CGFloat = 1.0
    @State private var repetitionCount = 0
    @State private var instructionText = "Get Ready..."
    @State private var isAnimating = false // Prevent overlapping animations

    // State for audio players
    @State private var inhalePlayer: AVAudioPlayer? = nil
    @State private var exhalePlayer: AVAudioPlayer? = nil

    // Animation constants for 3 quick in / 3 quick out (Adjusted Speed)
    let quickInhaleDuration: Double = 0.165 // 10% Slower
    let quickExhaleDuration: Double = 0.22  // 10% Slower
    let pauseBetweenPulses: Double = 0.055 // 10% Slower
    let pauseBetweenInOut: Double = 1.0  // Set to 1 second
    let pauseBetweenReps: Double = 0.275 // 10% Slower

    let baseScale: CGFloat = 1.0
    let inhaleScaleStep1: CGFloat = 1.2
    let inhaleScaleStep2: CGFloat = 1.35
    let inhaleScaleStep3: CGFloat = 1.5 // Max scale
    let exhaleScaleStep1: CGFloat = 1.3 // Start contracting from max
    let exhaleScaleStep2: CGFloat = 1.15
    // Final exhale returns to baseScale

    // Calculate total time for one rep & determine number of reps for ~30s
    var singleRepDuration: Double {
        (3 * quickInhaleDuration + 2 * pauseBetweenPulses) + pauseBetweenInOut +
        (3 * quickExhaleDuration + 2 * pauseBetweenPulses) + pauseBetweenReps
    }
    var totalRepetitions: Int {
        max(1, Int(30.0 / singleRepDuration)) // Aim for ~30 seconds, at least 1 rep
    }

    var body: some View {
        NavigationView { // Provides a title bar and standard controls
            ZStack {
                // Background Gradient - reverted
                LinearGradient(
                  gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
                .ignoresSafeArea() // Extend gradient to screen edges

                VStack(spacing: 40) { // Increased spacing
                    Spacer()

                    Text(instructionText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .id("instruction_" + instructionText) // Force view update on text change
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))

                    // Animated Circle
                    Circle()
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: 150, height: 150)
                        .scaleEffect(scale)
                        .shadow(radius: 10)
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2)) // Optional border

                    Spacer()
                    Text("Rep: \(repetitionCount)/\(totalRepetitions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Quick Reset") // More fitting title
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        stopSounds() // Stop sounds if × is tapped
                        isAnimating = false // Stop animation if × is tapped
                        dismiss() // Dismiss the sheet
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                prepareSounds() // Load sounds when view appears
                if !isAnimating { startBreathingCycle() }
            }
            .onDisappear {
                stopSounds() // Stop sounds
                isAnimating = false // Stop animation if view disappears
            }
        }
    }

    // --- Audio Functions --- 

    func prepareSounds() {
        // Prepare Inhale Sound
        if let inhaleUrl = Bundle.main.url(forResource: "inhale", withExtension: "wav") {
            do {
                inhalePlayer = try AVAudioPlayer(contentsOf: inhaleUrl)
                inhalePlayer?.prepareToPlay()
            } catch {
                print("Error loading inhale sound: \(error.localizedDescription)")
                // Handle error appropriately - maybe disable sound feature
            }
        } else {
            print("Inhale sound file not found.")
        }

        // Prepare Exhale Sound
        if let exhaleUrl = Bundle.main.url(forResource: "exhale", withExtension: "wav") {
            do {
                exhalePlayer = try AVAudioPlayer(contentsOf: exhaleUrl)
                exhalePlayer?.prepareToPlay()
            } catch {
                print("Error loading exhale sound: \(error.localizedDescription)")
            }
        } else {
            print("Exhale sound file not found.")
        }
    }

    func playInhaleSound() {
        inhalePlayer?.stop() // Stop previous playback if any
        inhalePlayer?.currentTime = 0 // Rewind
        inhalePlayer?.play()
    }

    func playExhaleSound() {
        exhalePlayer?.stop()
        exhalePlayer?.currentTime = 0
        exhalePlayer?.play()
    }

    func stopSounds() {
        inhalePlayer?.stop()
        exhalePlayer?.stop()
    }

    // --- Animation Functions --- 

    // Function to manage the breathing animation sequence
    func startBreathingCycle() {
        guard !isAnimating else { return }
        isAnimating = true
        scale = baseScale
        repetitionCount = 0
        instructionText = "Get Ready..."

        // Initial delay before starting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard isAnimating else { return }
            performRepetition()
        }
    }

    func performRepetition() {
        guard isAnimating else { return }
        guard repetitionCount < totalRepetitions else {
            instructionText = "Well done!"
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 withAnimation(.easeInOut(duration: 0.5)) { scale = baseScale }
             }
            isAnimating = false
            return
        }

        repetitionCount += 1
        let currentRep = repetitionCount
        var delay: Double = 0.0

        // --- 3 Quick Inhales --- 
        // Inhale 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isAnimating else { return }
            instructionText = "Inhale 1 (Rep \(currentRep))"
            playInhaleSound() // Play Sound
            withAnimation(.easeOut(duration: quickInhaleDuration)) { scale = inhaleScaleStep1 }
        }
        delay += quickInhaleDuration + pauseBetweenPulses

        // Inhale 2
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isAnimating else { return }
            instructionText = "Inhale 2 (Rep \(currentRep))"
            playInhaleSound() // Play Sound
            withAnimation(.easeOut(duration: quickInhaleDuration)) { scale = inhaleScaleStep2 }
        }
        delay += quickInhaleDuration + pauseBetweenPulses

        // Inhale 3
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isAnimating else { return }
            instructionText = "Inhale 3 (Rep \(currentRep))"
            playInhaleSound() // Play Sound
            withAnimation(.easeOut(duration: quickInhaleDuration)) { scale = inhaleScaleStep3 }
        }
        delay += quickInhaleDuration + pauseBetweenInOut

        // --- 3 Quick Exhales --- 
        // Exhale 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isAnimating else { return }
            instructionText = "Exhale 1 (Rep \(currentRep))"
            playExhaleSound() // Play Sound
            withAnimation(.easeIn(duration: quickExhaleDuration)) { scale = exhaleScaleStep1 }
        }
        delay += quickExhaleDuration + pauseBetweenPulses

        // Exhale 2
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isAnimating else { return }
            instructionText = "Exhale 2 (Rep \(currentRep))"
            playExhaleSound() // Play Sound
            withAnimation(.easeIn(duration: quickExhaleDuration)) { scale = exhaleScaleStep2 }
        }
        delay += quickExhaleDuration + pauseBetweenPulses

        // Exhale 3
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isAnimating else { return }
            instructionText = "Exhale 3 (Rep \(currentRep))"
            playExhaleSound() // Play Sound
            withAnimation(.easeIn(duration: quickExhaleDuration)) { scale = baseScale }
        }
        delay += quickExhaleDuration + pauseBetweenReps

        // --- Schedule Next Repetition --- 
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
             guard isAnimating else { return }
             performRepetition() // Start the next cycle
        }
    }
}

#Preview {
    BreatheView()
} 
