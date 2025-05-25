// MARK: - MeditateView.swift

import SwiftUI
import Combine // Needed for Timer
import AVFoundation // Keep for AVAudioPlayer

struct MeditateView: View {
    @Environment(\.dismiss) var dismiss // For modal dismissal

    // --- Configuration for Local Audio Files ---
    // Assumes files named instruction_0.mp3, instruction_1.mp3, etc. are in the bundle.
    private let instructionAudioFileBaseName = "instruction_"
    private let instructionAudioFileExtension = "mp3" // Or "wav", etc.
    // -----------------------------------------

    // MARK: - State Variables

    // Timer and Time Tracking
    @State private var timerSubscription: Cancellable? = nil
    @State private var totalDuration: Int = 300
    @State private var timeRemaining: Int = 300
    @State private var elapsedSecondsInPhase: Int = 0

    // Meditation State
    @State private var isMeditating: Bool = false
    @State private var currentPhaseIndex: Int = 0
    @State private var isSpeaking: Bool = false // Track if audio is currently playing

    // Audio Playback (for local files)
    @State private var audioPlayer: AVAudioPlayer? = nil

    // Instructions
    let instructionPhases: [(text: String, duration: Int)] = [
        (text: "Find a comfortable position and gently close your eyes.", duration: 10),
        (text: "Listen to the sounds around you. Notice them without judgment.", duration: 45),
        (text: "Shift your attention to the space in front of you, behind your closed eyelids.", duration: 15),
        (text: "Rest your attention here gently.", duration: 75),
        (text: "If thoughts arise, acknowledge thinking, then gently guide your focus back.", duration: 75),
        (text: "Rest your attention here gently.", duration: 60),
        (text: "The session is ending soon.", duration: 10),
        (text: "Gently bring awareness back. Open your eyes when ready.", duration: 10)
    ]

    // MARK: - Computed Properties
    var currentInstruction: String {
        guard currentPhaseIndex >= 0 && currentPhaseIndex < instructionPhases.count else { return isMeditating ? "Finishing..." : "Ready?" }
        return instructionPhases[currentPhaseIndex].text
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Body
    var body: some View {
        NavigationView { // Wrap in NavigationView for toolbar
            ZStack {
                // Background (Consistent theme)
                LinearGradient(
                  gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Instruction Text Area
                    Text(currentInstruction)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .frame(minHeight: 100, alignment: .center) // Ensure space and center alignment
                        .id("instruction_\(currentPhaseIndex)") // Help SwiftUI notice changes
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))

                    // Timer Display
                    Text(formattedTime)
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .padding(.bottom, 30)

                    // Control Button
                    Button {
                        if isMeditating {
                            stopMeditation()
                        } else {
                            startMeditation()
                        }
                    } label: {
                        Text(isMeditating ? "Stop" : "Start Meditation")
                            .font(.headline)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(isMeditating ? Color.mint.opacity(0.8) : Color.blue.opacity(0.7))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .overlay( // Show subtle indicator while playing audio
                               isSpeaking ? Image(systemName: "speaker.wave.2.fill").foregroundColor(.white).padding(.trailing) : nil,
                               alignment: .trailing
                            )
                    }
                    .padding(.horizontal)
                    .disabled(isSpeaking && !isMeditating) // Disable start if still speaking

                    // TODO: Optional - Add a Picker for duration selection here

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Mindful Listening")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        stopMeditation() // Stop meditation if running
                        dismiss() // Dismiss the modal
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onDisappear {
                // Ensure timer stops if the view is dismissed
                stopMeditation()
            }
        }
    }

    // MARK: - Functions

    func startMeditation() {
        guard !isMeditating else { return }
        isMeditating = true
        currentPhaseIndex = 0
        elapsedSecondsInPhase = 0
        totalDuration = instructionPhases.dropLast().reduce(0) { $0 + $1.duration }
        timeRemaining = totalDuration
        updateInstructionAndPlayAudio() // Play first instruction audio

        // Start the timer
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in timerFired() }
    }

    func stopMeditation() {
        audioPlayer?.stop() // Stop any current playback
        isSpeaking = false
        isMeditating = false
        timerSubscription?.cancel()
        timerSubscription = nil
        timeRemaining = instructionPhases.dropLast().reduce(0) { $0 + $1.duration }
        currentPhaseIndex = 0
        elapsedSecondsInPhase = 0
        // Reset instruction text visually if needed
    }

    func timerFired() {
        guard isMeditating else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
            elapsedSecondsInPhase += 1
            if currentPhaseIndex < instructionPhases.count - 1 {
                let currentPhaseDuration = instructionPhases[currentPhaseIndex].duration
                if elapsedSecondsInPhase >= currentPhaseDuration {
                    currentPhaseIndex += 1
                    elapsedSecondsInPhase = 0
                    updateInstructionAndPlayAudio() // Play next instruction audio
                }
            }
        } else {
            // Timer finished
            if currentPhaseIndex < instructionPhases.count - 1 {
                 currentPhaseIndex = instructionPhases.count - 1
                 updateInstructionAndPlayAudio() // Play final instruction audio
            }
            timerSubscription?.cancel()
        }
    }

    func updateInstructionAndPlayAudio() {
        // Text updates automatically via @State
        playLocalInstructionAudio(phaseIndex: currentPhaseIndex)
    }

    // MARK: - Local Audio Playback
    func playLocalInstructionAudio(phaseIndex: Int) {
        audioPlayer?.stop() // Stop previous playback
        isSpeaking = false // Reset speaking state initially

        let fileName = "\(instructionAudioFileBaseName)\(phaseIndex)"

        guard let url = Bundle.main.url(forResource: fileName, withExtension: instructionAudioFileExtension) else {
            print("Error: Audio file not found in bundle: \(fileName).\(instructionAudioFileExtension)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isSpeaking = true
            print("Playing: \(fileName).\(instructionAudioFileExtension)")

            // --- Handling Playback Completion (Simplified) ---
            // Ideally, use AVAudioPlayerDelegate for accuracy.
            // This Dispatch queue adds a delay slightly longer than the audio duration.
            let estimatedDelay = (audioPlayer?.duration ?? 1.0) + 0.1 // Add small buffer
            DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDelay) {
                // Only set isSpeaking to false if this specific playback instance is finishing
                // (A check against the player instance could be added for more safety)
                 if isSpeaking { // Check if it wasn't stopped manually
                     isSpeaking = false
                     print("Finished playing: \(fileName).\(instructionAudioFileExtension)")
                 }
            }
            // -------------------------------------------------

        } catch {
            print("Error initializing or playing audio file \(fileName): \(error)")
            isSpeaking = false // Ensure state is reset on error
        }
    }
}

#Preview {
    // Preview as a modal sheet
    MeditateView()
} 