// MARK: - HotChocolateGuideAudioView.swift

import SwiftUI
import AVFoundation
import Combine

struct HotChocolateGuideAudioView: View {
    
    // --- Configuration ---
//    private let audioFileName = "hot_chocolate_guide" // Add this file (e.g., hot_chocolate_guide.mp3)
  
    private let audioFileName = "instruction_0" //
    private let audioFileExtension = "mp3" // Or wav, etc.
    // ---------------------

    // MARK: - State Variables
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var isPlaying: Bool = false
    @State private var totalDuration: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    @State private var timerSubscription: Cancellable? = nil
    @State private var errorMessage: String? = nil
    
    // Removed State for Animation Bars
    // @State private var barScales: [CGFloat] = [0.3, 0.3, 0.3, 0.3, 0.3]
    // private let animationDuration = 0.4

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background (Consistent theme)
            LinearGradient(
                gradient: Gradient(colors: [Color.brown.opacity(0.2), Color(red: 0.5, green: 0.35, blue: 0.25).opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.brown.opacity(0.8))
                    .padding(.bottom, 20)

                Text("Mindful Hot Chocolate Audio")
                    .font(.title)
                    .fontWeight(.semibold)
                    
                // --- Removed Animation Bars --- 
                // HStack(spacing: 4) { ... }
                // --- End Removed Animation Bars ---

                if let errorMessage = errorMessage {
                     Text(errorMessage)
                         .foregroundColor(.red)
                         .padding()
                 }

                // Player Controls
                VStack(spacing: 15) {
                    // Time Display
                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(totalDuration))
                    }
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)

                    // Progress Bar (Simple version)
                    ProgressView(value: currentTime, total: totalDuration)
                        .progressViewStyle(.linear)
                        .tint(.brown)

                    // Play/Pause Button
                    Button {
                        togglePlayback()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            .foregroundColor(.brown.opacity(0.9))
                    }
                    .disabled(errorMessage != nil) // Disable if audio failed to load
                }
                .padding(.horizontal, 40)

                Spacer()
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Audio Guide")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupAudioPlayer)
        .onDisappear(perform: stopAndCleanup)
        // --- Removed onChange modifier --- 
        // .onChange(of: isPlaying) { ... }
        // --- End Removed onChange ---
    }

    // MARK: - Animation Functions (Removed)
    // func startBarAnimation() { ... }
    // func resetBarAnimation() { ... }

    // MARK: - Audio Functions
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: audioFileExtension) else {
            print("Error: Audio file not found: \(audioFileName).\(audioFileExtension)")
            errorMessage = "Audio file not found."
            return
        }

        do {
            // Configure audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            totalDuration = audioPlayer?.duration ?? 0.0
            errorMessage = nil // Clear error if successful
        } catch {
            print("Error initializing audio player: \(error)")
            errorMessage = "Failed to load audio."
        }
    }

    func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
            stopTimer()
        } else {
            player.play()
            startTimer()
        }
        isPlaying.toggle()
    }

    func stopAndCleanup() {
        audioPlayer?.stop()
        isPlaying = false
        stopTimer()
        // Deactivate audio session (optional, depends on app structure)
        // try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Timer Functions
    func startTimer() {
        // Invalidate existing timer if any
        stopTimer()
        // Create a new timer that fires frequently to update currentTime
        timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateProgress()
            }
    }

    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    func updateProgress() {
        guard let player = audioPlayer, isPlaying else { return }
        currentTime = player.currentTime
        
        // Check if playback finished
        if currentTime >= totalDuration {
            player.stop() // Ensure it stops
            player.currentTime = 0 // Reset to beginning
            isPlaying = false
            currentTime = 0 // Reset timer display
            stopTimer()
        }
    }

    // MARK: - Helper
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationView {
        HotChocolateGuideAudioView()
    }
} 
