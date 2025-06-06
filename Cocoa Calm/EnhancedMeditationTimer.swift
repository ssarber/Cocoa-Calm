//
//  EnhancedMeditationTimer.swift
//  Cocoa Calm
//
//  Advanced meditation timer with ambient sounds and session tracking
//

import SwiftUI
import AVFoundation
import Combine

struct EnhancedMeditationTimer: View {
    @EnvironmentObject var contentManager: ContentManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    let content: ContentItem?
    
    @StateObject private var timerManager = MeditationTimerManager()
    @State private var showingAmbientSounds = false
    @State private var showingSettings = false
    @State private var selectedDuration: TimeInterval
    @State private var customDuration: String = ""
    @State private var showingCustomDuration = false
    @State private var currentSession: MeditationSession?
    
    // Preset durations in minutes
    private let presetDurations: [TimeInterval] = [300, 600, 900, 1200, 1800, 2400, 3600] // 5, 10, 15, 20, 30, 40, 60 minutes
    
    init(content: ContentItem? = nil) {
        self.content = content
        self._selectedDuration = State(initialValue: content?.duration ?? 600) // Default 10 minutes
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with breathing animation
                animatedBackgroundView
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Content info (if provided)
                    if let content = content {
                        contentInfoSection(content)
                    }
                    
                    // Timer display
                    timerDisplaySection
                    
                    // Control buttons
                    controlButtonsSection
                    
                    // Duration selector (when not started)
                    if timerManager.state == .stopped {
                        durationSelectorSection
                    }
                    
                    // Ambient sounds (Premium only)
                    if subscriptionManager.canAccessPremiumContent() && timerManager.state != .stopped {
                        ambientSoundsSection
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .navigationBarHidden(true)
            .onAppear {
                setupTimer()
            }
            .onDisappear {
                completeSession()
            }
            .sheet(isPresented: $showingAmbientSounds) {
                AmbientSoundsView(timerManager: timerManager)
            }
        }
    }
    
    // MARK: - Background View
    
    private var animatedBackgroundView: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.4),
                    Color.indigo.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Breathing circles
            if timerManager.state == .running {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .scaleEffect(timerManager.breathingScale)
                        .opacity(0.6 - Double(index) * 0.2)
                        .animation(
                            .easeInOut(duration: 4.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                            value: timerManager.breathingScale
                        )
                }
            }
        }
    }
    
    // MARK: - Content Info Section
    
    private func contentInfoSection(_ content: ContentItem) -> some View {
        VStack(spacing: 8) {
            Text(content.title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(content.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            if content.isPremium && !subscriptionManager.canAccessPremiumContent() {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("Premium Content")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.black.opacity(0.3))
                .cornerRadius(12)
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Timer Display Section
    
    private var timerDisplaySection: some View {
        VStack(spacing: 20) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: CGFloat(timerManager.progress))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: timerManager.progress)
                
                // Time display
                VStack(spacing: 8) {
                    Text(formatTime(timerManager.timeRemaining))
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    if timerManager.state == .running {
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    } else if timerManager.state == .paused {
                        Text("paused")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("ready")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    
    // MARK: - Control Buttons Section
    
    private var controlButtonsSection: some View {
        HStack(spacing: 40) {
            // Cancel/Stop button
            Button {
                if timerManager.state == .stopped {
                    dismiss()
                } else {
                    stopTimer()
                }
            } label: {
                Image(systemName: timerManager.state == .stopped ? "xmark" : "stop.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(.black.opacity(0.3))
                    .cornerRadius(30)
            }
            
            // Play/Pause button
            Button {
                switch timerManager.state {
                case .stopped:
                    startTimer()
                case .running:
                    pauseTimer()
                case .paused:
                    resumeTimer()
                }
            } label: {
                Image(systemName: playButtonIcon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(.white.opacity(0.2))
                    .cornerRadius(40)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.5), lineWidth: 2)
                    )
            }
            
            // Settings button
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(.black.opacity(0.3))
                    .cornerRadius(30)
            }
        }
    }
    
    // MARK: - Duration Selector Section
    
    private var durationSelectorSection: some View {
        VStack(spacing: 16) {
            Text("Duration")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(presetDurations, id: \.self) { duration in
                        DurationButton(
                            duration: duration,
                            isSelected: selectedDuration == duration,
                            onTap: {
                                selectedDuration = duration
                                timerManager.setDuration(duration)
                            }
                        )
                    }
                    
                    // Custom duration button
                    Button {
                        showingCustomDuration = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.title3)
                            Text("Custom")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.2))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Custom Duration", isPresented: $showingCustomDuration) {
            TextField("Minutes", text: $customDuration)
                .keyboardType(.numberPad)
            Button("Set") {
                if let minutes = Double(customDuration), minutes > 0 {
                    selectedDuration = minutes * 60
                    timerManager.setDuration(selectedDuration)
                }
                customDuration = ""
            }
            Button("Cancel", role: .cancel) {
                customDuration = ""
            }
        } message: {
            Text("Enter the duration in minutes")
        }
    }
    
    // MARK: - Ambient Sounds Section
    
    private var ambientSoundsSection: some View {
        Button {
            showingAmbientSounds = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: timerManager.isPlayingAmbientSound ? "speaker.wave.2.fill" : "speaker.fill")
                    .foregroundColor(.white)
                
                Text(timerManager.isPlayingAmbientSound ? "Ambient: \(timerManager.currentAmbientSound)" : "Add Ambient Sound")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.black.opacity(0.3))
            .cornerRadius(20)
        }
    }
    
    // MARK: - Computed Properties
    
    private var playButtonIcon: String {
        switch timerManager.state {
        case .stopped: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        }
    }
    
    // MARK: - Timer Control Methods
    
    private func setupTimer() {
        timerManager.setDuration(selectedDuration)
        
        if let content = content {
            currentSession = contentManager.startSession(for: content)
        }
    }
    
    private func startTimer() {
        timerManager.start()
        
        if currentSession == nil, let content = content {
            currentSession = contentManager.startSession(for: content)
        }
    }
    
    private func pauseTimer() {
        timerManager.pause()
    }
    
    private func resumeTimer() {
        timerManager.resume()
    }
    
    private func stopTimer() {
        timerManager.stop()
        completeSession()
        dismiss()
    }
    
    private func completeSession() {
        guard let session = currentSession else { return }
        
        let completedDuration = selectedDuration - timerManager.timeRemaining
        contentManager.completeSession(session, completedDuration: completedDuration)
        currentSession = nil
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Duration Button

struct DurationButton: View {
    let duration: TimeInterval
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Int(duration / 60))")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("min")
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? .white : .white.opacity(0.2))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? .clear : .white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Meditation Timer Manager

@MainActor
class MeditationTimerManager: ObservableObject {
    
    enum TimerState {
        case stopped, running, paused
    }
    
    @Published var state: TimerState = .stopped
    @Published var timeRemaining: TimeInterval = 600 // Default 10 minutes
    @Published var totalDuration: TimeInterval = 600
    @Published var progress: Double = 0
    @Published var breathingScale: CGFloat = 1.0
    @Published var isPlayingAmbientSound = false
    @Published var currentAmbientSound = ""
    
    private var timer: Timer?
    private var ambientPlayer: AVAudioPlayer?
    
    init() {
        startBreathingAnimation()
    }
    
    func setDuration(_ duration: TimeInterval) {
        guard state == .stopped else { return }
        
        totalDuration = duration
        timeRemaining = duration
        progress = 0
    }
    
    func start() {
        guard state == .stopped else { return }
        
        state = .running
        startTimer()
    }
    
    func pause() {
        guard state == .running else { return }
        
        state = .paused
        stopTimer()
    }
    
    func resume() {
        guard state == .paused else { return }
        
        state = .running
        startTimer()
    }
    
    func stop() {
        state = .stopped
        stopTimer()
        
        timeRemaining = totalDuration
        progress = 0
        
        stopAmbientSound()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
                self.progress = 1.0 - (self.timeRemaining / self.totalDuration)
            } else {
                self.timerCompleted()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerCompleted() {
        state = .stopped
        stopTimer()
        
        // Play completion sound or haptic
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        timeRemaining = 0
        progress = 1.0
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.2
        }
    }
    
    func playAmbientSound(_ soundName: String) {
        stopAmbientSound()
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Could not find ambient sound: \(soundName)")
            return
        }
        
        do {
            ambientPlayer = try AVAudioPlayer(contentsOf: url)
            ambientPlayer?.numberOfLoops = -1 // Loop indefinitely
            ambientPlayer?.volume = 0.3
            ambientPlayer?.play()
            
            isPlayingAmbientSound = true
            currentAmbientSound = soundName.capitalized
        } catch {
            print("Failed to play ambient sound: \(error)")
        }
    }
    
    func stopAmbientSound() {
        ambientPlayer?.stop()
        ambientPlayer = nil
        isPlayingAmbientSound = false
        currentAmbientSound = ""
    }
}

// MARK: - Ambient Sounds View

struct AmbientSoundsView: View {
    @ObservedObject var timerManager: MeditationTimerManager
    @Environment(\.dismiss) private var dismiss
    
    private let ambientSounds = [
        ("rain", "Rain", "Rain drops on leaves"),
        ("ocean", "Ocean Waves", "Gentle ocean sounds"),
        ("forest", "Forest", "Birds and wind in trees"),
        ("fire", "Crackling Fire", "Warm fireplace sounds"),
        ("wind", "Mountain Wind", "Peaceful mountain breeze")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    Section {
                        Button {
                            timerManager.stopAmbientSound()
                        } label: {
                            HStack {
                                Image(systemName: "speaker.slash.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("No Sound")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Silent meditation")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if !timerManager.isPlayingAmbientSound {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        ForEach(ambientSounds, id: \.0) { sound in
                            Button {
                                timerManager.playAmbientSound(sound.0)
                            } label: {
                                HStack {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(sound.1)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text(sound.2)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if timerManager.currentAmbientSound.lowercased() == sound.1.lowercased() {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } header: {
                        Text("Ambient Sounds")
                    } footer: {
                        Text("Ambient sounds can help maintain focus during meditation. Choose what feels right for your practice.")
                    }
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .navigationTitle("Ambient Sounds")
            .navigationBarTitleDisplayMode(.inline)
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

struct EnhancedMeditationTimer_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedMeditationTimer()
            .environmentObject(ContentManager())
            .environmentObject(SubscriptionManager())
    }
}
