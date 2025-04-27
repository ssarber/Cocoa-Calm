// MARK: - HotChocolateGuideAudioView.swift

import SwiftUI
import AVFoundation
import Combine

struct HotChocolateGuideAudioView: View {
    
    // --- Configuration ---
    private let audioFileName = "hot_chocolate_guide" // Add this file (e.g., hot_chocolate_guide.mp3)
  
    private let audioFileExtension = "mp3" // Or wav, etc.
    // ---------------------

    // MARK: - State Variables
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var isPlaying: Bool = false
    @State private var totalDuration: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    @State private var timerSubscription: Cancellable? = nil
    @State private var errorMessage: String? = nil
    
    // State for Swirl Animation
    @State private var rotationAngle1: Angle = .zero
    @State private var rotationAngle2: Angle = .zero
    @State private var rotationAngle3: Angle = .zero

    // MARK: - Body
    var body: some View {
        ZStack {
            // --- Swirling Background Animation --- 
            ZStack {
                 Circle() // Largest, darkest base
                    .fill(Color(red: 0.3, green: 0.15, blue: 0.05).opacity(0.8))
                    .frame(width: 600, height: 600)
                    .offset(x: -100, y: -100)
                    .rotationEffect(rotationAngle1)

                 Circle() // Medium, slightly lighter
                    .fill(Color.brown.opacity(0.6))
                    .frame(width: 500, height: 500)
                    .offset(x: 100, y: 50)
                    .rotationEffect(rotationAngle2)

                 Circle() // Smaller, highlight tone
                     .fill(Color(red: 0.6, green: 0.4, blue: 0.2).opacity(0.5))
                     .frame(width: 400, height: 400)
                     .offset(x: -50, y: 100)
                     .rotationEffect(rotationAngle3)
            }
            .blur(radius: 60) // Blend the shapes smoothly
            .ignoresSafeArea() // Extend to screen edges
            // --- End Swirling Background --- 
            
            // Removed Static Gradient Background
            /*
            LinearGradient(
                gradient: Gradient(colors: [Color.brown.opacity(0.2), Color(red: 0.5, green: 0.35, blue: 0.25).opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            */

            // --- Foreground Content ---
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white.opacity(0.9)) // Change color for contrast
                    .shadow(radius: 5) // Add shadow for visibility
                    .padding(.bottom, 20)

                Text("Mindful Hot Chocolate Audio")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white) // Change color for contrast
                    .shadow(radius: 3)

                if let errorMessage = errorMessage {
                     Text(errorMessage)
                         .foregroundColor(.red)
                         .padding()
                         .background(.ultraThinMaterial)
                         .cornerRadius(10)
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
                    .foregroundColor(.white.opacity(0.8)) // Change color

                    // Progress Bar (REMOVED)
                    /*
                    ProgressView(value: currentTime, total: totalDuration)
                        .progressViewStyle(.linear)
                        .tint(.white.opacity(0.7)) // Change tint
                    */

                    // Play/Pause Button
                    Button {
                        togglePlayback()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 3)
                    }
                    .disabled(errorMessage != nil)
                }
                .padding(.horizontal, 40)
                // Add a background material for better readability of controls (REMOVED)
                .padding(.vertical, 20)
                // .background(.black.opacity(0.15))
                // .cornerRadius(15)

                Spacer()
                Spacer()
            }
            .padding()
            // --- End Foreground Content ---
        }
        .navigationTitle("Audio Guide")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupAudioPlayer)
        .onDisappear(perform: stopAndCleanup)
        .onChange(of: isPlaying) { playing in
            if playing {
                startSwirlAnimation()
            } else {
                stopSwirlAnimation()
            }
        }
    }

    // MARK: - Animation Functions
    func startSwirlAnimation() {
         withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
             rotationAngle1 = .degrees(360)
         }
         withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) {
             rotationAngle2 = .degrees(-360) // Rotate opposite direction
         }
        withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
             rotationAngle3 = .degrees(360)
         }
    }

    func stopSwirlAnimation() {
         // Stop the repeating animation by applying a non-repeating one
         // Setting the angle back to zero (or current value) without repeat stops it.
          withAnimation(.easeInOut(duration: 0.5)) {
              // Keep the current angle visually, but the repeatForever is removed
              // Or reset to zero for a cleaner stop:
              rotationAngle1 = .zero
              rotationAngle2 = .zero
              rotationAngle3 = .zero
          }
    }

    // MARK: - Audio Functions
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: audioFileExtension) else {
            print("Error: Audio file not found: \(audioFileName).\(audioFileExtension)")
            errorMessage = "Audio file not found."
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            totalDuration = audioPlayer?.duration ?? 0.0
            errorMessage = nil
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
    }
    
    // MARK: - Timer Functions
    func startTimer() {
        stopTimer()
        timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in updateProgress() }
    }

    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    func updateProgress() {
        guard let player = audioPlayer, player.isPlaying else { 
             if isPlaying { 
                 isPlaying = false
                 stopTimer()
                 currentTime = 0
             }
             return 
         }
        currentTime = player.currentTime
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
