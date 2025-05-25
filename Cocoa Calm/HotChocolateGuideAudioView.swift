import SwiftUI
import AVFoundation
import Combine

// Placeholder for your actual subscription management
class SubscriptionManager: ObservableObject {
    @Published var isSubscribed: Bool = false // Default to not subscribed

    // In a real app, this would involve StoreKit and server validation
    func startFreeTrial() {
        // Simulate starting a trial
        self.isSubscribed = true
        print("Free trial started. User is now subscribed.")
    }

    func checkSubscriptionStatus() {
        // In a real app, load status from UserDefaults, Keychain, or server
        // For this example, it just remains its current state unless startFreeTrial is called
        print("Checked subscription status: \(isSubscribed)")
    }
}

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            Text("Unlock Full Access")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .padding()

            Text("Start your free trial to listen to the Mindful Hot Chocolate audio guide and access all premium features.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Button {
                subscriptionManager.startFreeTrial()
                // In a real app, you'd handle StoreKit purchase flow here.
                // If successful, then update subscriptionManager.isSubscribed
                // and then dismiss.
                dismiss()
            } label: {
                Text("Start Free Trial")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            .padding(.horizontal, 40)

            Button {
                dismiss()
            } label: {
                Text("Not Now")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .ignoresSafeArea()
    }
}

struct HotChocolateGuideAudioView: View {
    @Environment(\.dismiss) var dismiss // For modal dismissal
    
    // --- Configuration ---
    private let audioFileName = "hot_chocolate_guide"
    private let audioFileExtension = "mp3"
    // ---------------------

    // MARK: - State Variables for Audio Player
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

    // Paywall and subscription state
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var showPaywallSheet: Bool = false

    // MARK: - Body
    var body: some View {
        Group {
            if subscriptionManager.isSubscribed {
                audioPlayerContentView
            } else {
                lockedScreenView
            }
        }
        .onAppear {
            setupAudioPlayer() // Prepare audio resources
            subscriptionManager.checkSubscriptionStatus() // Check current status
            if !subscriptionManager.isSubscribed {
                showPaywallSheet = true // Present paywall if not subscribed
            }
        }
        .sheet(isPresented: $showPaywallSheet) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
    }

    // MARK: - Subviews
    var audioPlayerContentView: some View {
        NavigationView {
            ZStack {
                swirlingBackgroundView
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(radius: 5)
                        .padding(.bottom, 20)

                    Text("Mindful Hot Chocolate Audio")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(radius: 3)

                    if let errorMessage = errorMessage {
                         Text(errorMessage)
                             .foregroundColor(.red)
                             .padding()
                             .background(.ultraThinMaterial)
                             .cornerRadius(10)
                     }

                    VStack(spacing: 15) {
                        HStack {
                            Text(formatTime(currentTime))
                            Spacer()
                            Text(formatTime(totalDuration))
                        }
                        .font(.caption.monospaced())
                        .foregroundColor(.white.opacity(0.8))

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
                        .disabled(errorMessage != nil || audioPlayer == nil)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)

                    Spacer()
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Audio Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        stopAndCleanup() // Stop audio if playing
                        dismiss() // Dismiss the modal
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .onDisappear(perform: stopAndCleanup)
            .onChange(of: isPlaying) { newValue in // Updated onChange syntax
                if newValue {
                    startSwirlAnimation()
                } else {
                    stopSwirlAnimation()
                }
            }
        }
    }

    var lockedScreenView: some View {
        NavigationView {
            VStack(spacing: 25) {
                Spacer()
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.gray.opacity(0.8))
                
                Text("Premium Audio Guide")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Unlock this mindful audio experience with a free trial.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button {
                    showPaywallSheet = true
                } label: {
                    Text("Unlock with Free Trial")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 280)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.top)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .ignoresSafeArea()
            .navigationTitle("Content Locked")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss() // Dismiss the modal
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    var swirlingBackgroundView: some View {
        ZStack {
             Circle()
                .fill(Color(red: 0.3, green: 0.15, blue: 0.05).opacity(0.8))
                .frame(width: 600, height: 600)
                .offset(x: -100, y: -100)
                .rotationEffect(rotationAngle1)

             Circle()
                .fill(Color.brown.opacity(0.6))
                .frame(width: 500, height: 500)
                .offset(x: 100, y: 50)
                .rotationEffect(rotationAngle2)

             Circle()
                 .fill(Color(red: 0.6, green: 0.4, blue: 0.2).opacity(0.5))
                 .frame(width: 400, height: 400)
                 .offset(x: -50, y: 100)
                 .rotationEffect(rotationAngle3)
        }
        .blur(radius: 60)
        .ignoresSafeArea()
    }

    // MARK: - Animation Functions
    func startSwirlAnimation() {
         withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
             rotationAngle1 = .degrees(360)
         }
         withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) {
             rotationAngle2 = .degrees(-360)
         }
        withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
             rotationAngle3 = .degrees(360)
         }
    }

    func stopSwirlAnimation() {
          withAnimation(.easeInOut(duration: 0.5)) {
              rotationAngle1 = .zero // Or keep current angle if preferred for pause
              rotationAngle2 = .zero
              rotationAngle3 = .zero
          }
    }

    // MARK: - Audio Functions
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: audioFileExtension) else {
            print("Error: Audio file not found: \(audioFileName).\(audioFileExtension)")
            errorMessage = "Audio file not found. Please ensure '\(audioFileName).\(audioFileExtension)' is in your app bundle."
            return
        }

        do {
            // AVAudioSession configuration is not needed/available on macOS
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            totalDuration = audioPlayer?.duration ?? 0.0
            errorMessage = nil
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
            errorMessage = "Failed to load audio: \(error.localizedDescription)"
        }
    }

    func togglePlayback() {
        guard let player = audioPlayer else {
            errorMessage = "Audio player not ready."
            return
        }
        if isPlaying {
            player.pause()
            stopTimer()
        } else {
            // Ensure audio is ready before playing
            if player.duration > 0 { // Basic check if player is prepared
                player.play()
                startTimer()
            } else {
                errorMessage = "Audio not ready to play."
                // Optionally try to prepare again if it failed silently
                // player.prepareToPlay()
            }
        }
        isPlaying.toggle()
    }

    func stopAndCleanup() {
        audioPlayer?.stop()
        isPlaying = false
        stopTimer()
        // Optionally reset animation
        // stopSwirlAnimation()
    }
    
    // MARK: - Timer Functions
    func startTimer() {
        stopTimer() // Ensure any existing timer is cancelled
        timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateProgress()
            }
    }

    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    func updateProgress() {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            currentTime = player.currentTime
        } else {
            // If player is not playing, but our state `isPlaying` is true, it means playback just stopped (e.g. finished or paused by system)
            if isPlaying {
                isPlaying = false // Sync our state
                stopTimer()
                // Check if audio finished
                if currentTime >= totalDuration && totalDuration > 0 {
                    player.currentTime = 0 // Reset to beginning
                    self.currentTime = 0 // Update UI
                }
            }
        }
    }

    // MARK: - Helper
    func formatTime(_ time: TimeInterval) -> String {
        let value = max(0, time) // Ensure time is not negative
        let minutes = Int(value) / 60
        let seconds = Int(value) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    HotChocolateGuideAudioView()
}
