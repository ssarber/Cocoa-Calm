//
//  ContentManager.swift
//  Cocoa Calm
//
//  Comprehensive content management for premium meditation library
//

import Foundation
import SwiftUI

// MARK: - Progress Tracking Models

struct MeditationSession: Identifiable, Codable {
    let id = UUID()
    let contentId: String
    let startTime: Date
    let endTime: Date
    let completedDuration: TimeInterval
    let totalDuration: TimeInterval
    let category: ContentItem.ContentCategory
    let wasCompleted: Bool
    
    var completionPercentage: Double {
        guard totalDuration > 0 else { return 0 }
        return min(completedDuration / totalDuration, 1.0)
    }
}

struct UserProgress: Codable {
    var totalSessions: Int = 0
    var totalMinutesMeditated: Double = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastSessionDate: Date?
    var completedSessions: [MeditationSession] = []
    var favoriteCategories: [ContentItem.ContentCategory] = []
    
    mutating func addSession(_ session: MeditationSession) {
        completedSessions.append(session)
        totalSessions += 1
        totalMinutesMeditated += session.completedDuration / 60
        
        updateStreak(for: session.startTime)
        updateFavoriteCategories()
    }
    
    private mutating func updateStreak(for date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessionDate = calendar.startOfDay(for: date)
        
        if let lastDate = lastSessionDate {
            let lastSessionDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastSessionDay, to: sessionDate).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysDifference > 1 {
                // Streak broken
                currentStreak = 1
            }
            // Same day doesn't change streak
        } else {
            currentStreak = 1
        }
        
        lastSessionDate = date
        longestStreak = max(longestStreak, currentStreak)
        
        // Check if streak should be reset (missed yesterday)
        if calendar.dateComponents([.day], from: sessionDate, to: today).day ?? 0 > 1 {
            currentStreak = 0
        }
    }
    
    private mutating func updateFavoriteCategories() {
        let categoryCount = Dictionary(grouping: completedSessions, by: { $0.category })
            .mapValues { $0.count }
        
        favoriteCategories = categoryCount.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }
}

// MARK: - Content Manager

@MainActor
class ContentManager: ObservableObject {
    
    @Published var userProgress: UserProgress = UserProgress()
    @Published var recommendedContent: [ContentItem] = []
    @Published var todaysContent: [ContentItem] = []
    @Published var recentlyPlayed: [ContentItem] = []
    
    private let progressKey = "user_meditation_progress"
    
    init() {
        loadUserProgress()
        generateTodaysContent()
        generateRecommendations()
    }
    
    // MARK: - Session Management
    
    func startSession(for content: ContentItem) -> MeditationSession {
        let session = MeditationSession(
            contentId: content.id.uuidString,
            startTime: Date(),
            endTime: Date(), // Will be updated when session ends
            completedDuration: 0,
            totalDuration: content.duration,
            category: content.category,
            wasCompleted: false
        )
        return session
    }
    
    func completeSession(_ session: MeditationSession, completedDuration: TimeInterval) {
        let completedSession = MeditationSession(
            contentId: session.contentId,
            startTime: session.startTime,
            endTime: Date(),
            completedDuration: completedDuration,
            totalDuration: session.totalDuration,
            category: session.category,
            wasCompleted: completedDuration >= session.totalDuration * 0.8 // 80% completion counts as completed
        )
        
        userProgress.addSession(completedSession)
        saveUserProgress()
        
        // Update recommendations based on new session
        generateRecommendations()
        updateRecentlyPlayed(with: getContentById(session.contentId))
    }
    
    // MARK: - Content Discovery
    
    func generateTodaysContent() {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: Date())
        
        // Different content themes for different days
        switch dayOfWeek {
        case 1: // Sunday - Rest & Reflection
            todaysContent = getAllContent().filter { 
                $0.category == .sleep || $0.tags.contains("reflection") 
            }.prefix(4).map { $0 }
            
        case 2: // Monday - Energy & Focus
            todaysContent = getAllContent().filter { 
                $0.category == .focus || $0.tags.contains("energy") 
            }.prefix(4).map { $0 }
            
        case 3, 4, 5: // Tuesday-Thursday - Anxiety Relief
            todaysContent = getAllContent().filter { 
                $0.category == .anxiety || $0.category == .breathing 
            }.prefix(4).map { $0 }
            
        case 6: // Friday - Stress Relief
            todaysContent = getAllContent().filter { 
                $0.tags.contains("stress") || $0.category == .meditation 
            }.prefix(4).map { $0 }
            
        case 7: // Saturday - Mindful Living
            todaysContent = getAllContent().filter { 
                $0.category == .ritual || $0.tags.contains("mindfulness") 
            }.prefix(4).map { $0 }
            
        default:
            todaysContent = getAllContent().prefix(4).map { $0 }
        }
    }
    
    func generateRecommendations() {
        var recommendations: [ContentItem] = []
        
        // Based on favorite categories
        for category in userProgress.favoriteCategories.prefix(2) {
            let categoryContent = getAllContent().filter { $0.category == category }
            recommendations.append(contentsOf: categoryContent.prefix(2))
        }
        
        // Based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6...11: // Morning - energizing content
            recommendations.append(contentsOf: getAllContent().filter { 
                $0.tags.contains("morning") || $0.category == .focus 
            }.prefix(2))
            
        case 12...17: // Afternoon - focus content
            recommendations.append(contentsOf: getAllContent().filter { 
                $0.category == .anxiety || $0.tags.contains("stress") 
            }.prefix(2))
            
        case 18...23: // Evening - calming content
            recommendations.append(contentsOf: getAllContent().filter { 
                $0.category == .sleep || $0.tags.contains("evening") 
            }.prefix(2))
            
        default: // Late night/early morning - sleep content
            recommendations.append(contentsOf: getAllContent().filter { 
                $0.category == .sleep 
            }.prefix(2))
        }
        
        // Remove duplicates and shuffle
        let uniqueRecommendations = Array(Set(recommendations))
        recommendedContent = Array(uniqueRecommendations.shuffled().prefix(6))
    }
    
    private func updateRecentlyPlayed(with content: ContentItem?) {
        guard let content = content else { return }
        
        // Remove if already exists
        recentlyPlayed.removeAll { $0.id == content.id }
        
        // Add to beginning
        recentlyPlayed.insert(content, at: 0)
        
        // Keep only last 5 items
        if recentlyPlayed.count > 5 {
            recentlyPlayed = Array(recentlyPlayed.prefix(5))
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveUserProgress() {
        do {
            let data = try JSONEncoder().encode(userProgress)
            UserDefaults.standard.set(data, forKey: progressKey)
        } catch {
            print("Failed to save user progress: \(error)")
        }
    }
    
    private func loadUserProgress() {
        guard let data = UserDefaults.standard.data(forKey: progressKey) else { return }
        
        do {
            userProgress = try JSONDecoder().decode(UserProgress.self, from: data)
        } catch {
            print("Failed to load user progress: \(error)")
            userProgress = UserProgress()
        }
    }
    
    // MARK: - Content Access
    
    func getContentById(_ id: String) -> ContentItem? {
        return getAllContent().first { $0.id.uuidString == id }
    }
    
    func getAllContent() -> [ContentItem] {
        // Extended content library with realistic meditation content
        return [
            // Morning Meditations
            ContentItem(
                id: "morning_awakening",
                title: "Gentle Morning Awakening",
                description: "Start your day with intention and clarity",
                category: .meditation,
                subcategory: "Morning",
                duration: 600, // 10 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3", // Placeholder
                instructionPhases: nil,
                tags: ["morning", "energy", "awakening"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            ContentItem(
                id: "sunrise_meditation",
                title: "Sunrise Meditation",
                description: "Welcome the day with gratitude and purpose",
                category: .meditation,
                subcategory: "Morning",
                duration: 900, // 15 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["morning", "gratitude", "purpose"],
                difficulty: .intermediate,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            // Anxiety Relief
            ContentItem(
                id: "panic_attack_rescue",
                title: "Panic Attack Rescue",
                description: "Immediate relief for overwhelming anxiety",
                category: .anxiety,
                subcategory: "Crisis",
                duration: 300, // 5 minutes
                isPremium: false, // Free for accessibility
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["panic", "emergency", "breathing"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            ContentItem(
                id: "worry_release",
                title: "Releasing Worries",
                description: "Let go of anxious thoughts and find peace",
                category: .anxiety,
                subcategory: "Worry",
                duration: 720, // 12 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["worry", "release", "peace"],
                difficulty: .intermediate,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            ContentItem(
                id: "social_anxiety_calm",
                title: "Social Confidence Builder",
                description: "Build confidence for social situations",
                category: .anxiety,
                subcategory: "Social",
                duration: 840, // 14 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["social", "confidence", "anxiety"],
                difficulty: .intermediate,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            // Breathing Exercises
            ContentItem(
                id: "box_breathing",
                title: "Box Breathing Mastery",
                description: "Learn the powerful 4-4-4-4 breathing technique",
                category: .breathing,
                subcategory: "Technique",
                duration: 480, // 8 minutes
                isPremium: false,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: ["Inhale for 4", "Hold for 4", "Exhale for 4", "Hold for 4"],
                tags: ["technique", "calming", "focus"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            ContentItem(
                id: "coherent_breathing",
                title: "Coherent Breathing",
                description: "5-second in, 5-second out for heart-brain coherence",
                category: .breathing,
                subcategory: "Technique",
                duration: 600, // 10 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: ["Inhale for 5", "Exhale for 5"],
                tags: ["coherence", "balance", "heart"],
                difficulty: .intermediate,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            // Sleep Content
            ContentItem(
                id: "sleep_story_forest",
                title: "Forest Dreams",
                description: "A gentle story to guide you into peaceful sleep",
                category: .sleep,
                subcategory: "Sleep Story",
                duration: 1800, // 30 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["story", "forest", "dreams", "evening"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            ContentItem(
                id: "body_scan_sleep",
                title: "Sleep Body Scan",
                description: "Progressive relaxation for deep rest",
                category: .sleep,
                subcategory: "Body Scan",
                duration: 1200, // 20 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["body scan", "progressive", "relaxation", "evening"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            // Focus Content
            ContentItem(
                id: "concentration_builder",
                title: "Focus Builder",
                description: "Strengthen your attention and concentration",
                category: .focus,
                subcategory: "Concentration",
                duration: 900, // 15 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["concentration", "attention", "focus"],
                difficulty: .intermediate,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            ContentItem(
                id: "work_focus",
                title: "Pre-Work Focus",
                description: "Center yourself before important tasks",
                category: .focus,
                subcategory: "Work",
                duration: 420, // 7 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["work", "productivity", "preparation"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            // Mindful Rituals
            ContentItem(
                id: "mindful_coffee",
                title: "Mindful Coffee Ritual",
                description: "Transform your morning coffee into meditation",
                category: .ritual,
                subcategory: "Drinks",
                duration: 480, // 8 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["coffee", "morning", "mindfulness", "ritual"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            ContentItem(
                id: "mindful_walking",
                title: "Walking Meditation",
                description: "Find peace in movement and nature",
                category: .ritual,
                subcategory: "Movement",
                duration: 1080, // 18 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["walking", "movement", "nature", "mindfulness"],
                difficulty: .intermediate,
                createdDate: Date(),
                updatedDate: Date()
            ),
            
            // The original hot chocolate ritual
            ContentItem(
                id: "mindful_hot_chocolate",
                title: "Mindful Hot Chocolate",
                description: "Turn your favorite drink into meditation",
                category: .ritual,
                subcategory: "Drinks",
                duration: 1200, // 20 minutes
                isPremium: true,
                audioFileName: "hot_chocolate_guide.mp3",
                instructionPhases: nil,
                tags: ["ritual", "mindfulness", "comfort", "warm"],
                difficulty: .beginner,
                createdDate: Date(),
                updatedDate: Date()
            )
        ]
    }
}

// MARK: - ContentItem Extension for Hashable

extension ContentItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ContentItem, rhs: ContentItem) -> Bool {
        return lhs.id == rhs.id
    }
}
