//
//  Models.swift
//  Cocoa Calm
//
//  Enhanced data models for premium subscription platform
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - User Data Models

@Model
class UserProfile {
    var id: UUID = UUID()
    var createdDate: Date = Date()
    var lastActiveDate: Date = Date()
    var preferredSessionLength: Int = 10 // minutes
    var preferredTime: String = "morning" // morning, afternoon, evening
    var anxietyLevel: Int = 3 // 1-5 scale
    var meditationExperience: String = "beginner" // beginner, intermediate, advanced
    var goals: [String] = [] // anxiety relief, better sleep, focus, etc.
    
    init() {}
}

@Model
class MeditationSession {
    var id: UUID = UUID()
    var date: Date = Date()
    var duration: TimeInterval = 0
    var type: String = "" // meditation, breathing, ritual
    var contentId: String = "" // references content library
    var completed: Bool = false
    var rating: Int? = nil // 1-5 stars
    var moodBefore: Int? = nil // 1-5 scale
    var moodAfter: Int? = nil // 1-5 scale
    var notes: String = ""
    
    init(type: String, contentId: String, duration: TimeInterval = 0) {
        self.type = type
        self.contentId = contentId
        self.duration = duration
    }
}

@Model
class DailyCheckIn {
    var id: UUID = UUID()
    var date: Date = Date()
    var mood: Int = 3 // 1-5 scale
    var anxietyLevel: Int = 3 // 1-5 scale
    var sleepQuality: Int = 3 // 1-5 scale
    var stressLevel: Int = 3 // 1-5 scale
    var notes: String = ""
    var completedActivities: [String] = [] // meditation, breathing, ritual
    
    init() {}
}

// MARK: - Content Library Models

struct ContentItem: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: ContentCategory
    let subcategory: String?
    let duration: TimeInterval
    let isPremium: Bool
    let audioFileName: String?
    let instructionPhases: [InstructionPhase]?
    let tags: [String]
    let difficulty: ContentDifficulty
    let createdDate: Date
    let updatedDate: Date
    
    enum ContentCategory: String, CaseIterable, Codable {
        case crisis = "Crisis Intervention"
        case meditation = "Meditation"
        case breathing = "Breathing"
        case ritual = "Mindful Rituals"
        case masterclass = "Masterclasses"
        case live = "Live Sessions"
    }
    
    enum ContentDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

struct InstructionPhase: Codable {
    let phase: Int
    let duration: TimeInterval
    let instruction: String
    let audioFile: String?
}

// MARK: - Subscription Models

enum SubscriptionTier: String, CaseIterable {
    case free = "free"
    case premium = "premium"
    case lifetime = "lifetime"
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        case .lifetime: return "Lifetime"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable {
    case weekly = "cocoa_calm_weekly"
    case monthly = "cocoa_calm_monthly"
    case annual = "cocoa_calm_annual"
    case lifetime = "cocoa_calm_lifetime"
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        case .lifetime: return "Lifetime"
        }
    }
    
    var price: String {
        switch self {
        case .weekly: return "$4.99"
        case .monthly: return "$12.99"
        case .annual: return "$79.99"
        case .lifetime: return "$199.99"
        }
    }
    
    var savings: String? {
        switch self {
        case .weekly: return nil
        case .monthly: return "67% off weekly"
        case .annual: return "75% off weekly"
        case .lifetime: return "Best value"
        }
    }
}

// MARK: - Analytics Models

@Model
class UsageAnalytics {
    var id: UUID = UUID()
    var date: Date = Date()
    var sessionCount: Int = 0
    var totalDuration: TimeInterval = 0
    var featuresUsed: [String] = []
    var screenTime: TimeInterval = 0
    var lastFeatureUsed: String = ""
    
    init() {}
}

@Model
class ProgressMilestone {
    var id: UUID = UUID()
    var achievedDate: Date = Date()
    var milestoneType: String = "" // streak, mood_improvement, anxiety_reduction
    var value: Int = 0 // 7 for 7-day streak, etc.
    var isAchieved: Bool = false
    
    init(type: String, value: Int) {
        self.milestoneType = type
        self.value = value
    }
}

// MARK: - Mood & Wellness Tracking

enum MoodLevel: Int, CaseIterable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case good = 4
    case excellent = 5
    
    var displayName: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .excellent: return "Excellent"
        }
    }
    
    var emoji: String {
        switch self {
        case .veryLow: return "😰"
        case .low: return "😔"
        case .neutral: return "😐"
        case .good: return "😊"
        case .excellent: return "😄"
        }
    }
    
    var color: Color {
        switch self {
        case .veryLow: return .red
        case .low: return .orange
        case .neutral: return .yellow
        case .good: return .green
        case .excellent: return .blue
        }
    }
}

// MARK: - Content Library Data

class ContentLibrary: ObservableObject {
    @Published var allContent: [ContentItem] = []
    @Published var featuredContent: [ContentItem] = []
    @Published var newContent: [ContentItem] = []
    
    init() {
        loadContent()
    }
    
    private func loadContent() {
        // Load core content library as defined in PRD
        allContent = createCoreContentLibrary()
        featuredContent = Array(allContent.filter { $0.category == .crisis || $0.tags.contains("featured") }.prefix(5))
        newContent = Array(allContent.sorted { $0.createdDate > $1.createdDate }.prefix(3))
    }
    
    func getContent(by category: ContentItem.ContentCategory) -> [ContentItem] {
        return allContent.filter { $0.category == category }
    }
    
    func getPremiumContent() -> [ContentItem] {
        return allContent.filter { $0.isPremium }
    }
    
    func getFreeContent() -> [ContentItem] {
        return allContent.filter { !$0.isPremium }
    }
}

// MARK: - Core Content Library Creation

private func createCoreContentLibrary() -> [ContentItem] {
    var content: [ContentItem] = []
    let now = Date()
    
    // Crisis Intervention (Free)
    content.append(ContentItem(
        id: "crisis_sos_breathing",
        title: "SOS Breathing",
        description: "Quick 3-4-5 breathing pattern for immediate anxiety relief",
        category: .crisis,
        subcategory: "Emergency",
        duration: 180, // 3 minutes
        isPremium: false,
        audioFileName: "sos_breathing.mp3",
        instructionPhases: [
            InstructionPhase(phase: 1, duration: 60, instruction: "Find a comfortable position and close your eyes", audioFile: "instruction_0.mp3"),
            InstructionPhase(phase: 2, duration: 120, instruction: "Follow the breathing pattern: inhale for 3, hold for 4, exhale for 5", audioFile: "instruction_1.mp3")
        ],
        tags: ["crisis", "breathing", "anxiety", "featured"],
        difficulty: .beginner,
        createdDate: now,
        updatedDate: now
    ))
    
    content.append(ContentItem(
        id: "crisis_grounding",
        title: "5-4-3-2-1 Grounding",
        description: "Sensory grounding technique for panic attacks",
        category: .crisis,
        subcategory: "Emergency",
        duration: 300, // 5 minutes
        isPremium: false,
        audioFileName: "grounding_54321.mp3",
        instructionPhases: nil,
        tags: ["crisis", "grounding", "panic"],
        difficulty: .beginner,
        createdDate: now,
        updatedDate: now
    ))
    
    // Beginner Meditation Series (Premium)
    let beginnerSeries = [
        ("Introduction to Meditation", "Your first step into mindfulness practice", 300),
        ("Breath Awareness", "Learn to focus on your natural breath", 420),
        ("Body Scan Basics", "Gentle awareness of physical sensations", 600),
        ("Loving Kindness Intro", "Cultivating compassion for yourself", 480),
        ("Mindful Walking", "Meditation in gentle movement", 720),
        ("Dealing with Thoughts", "Understanding the nature of thinking", 540),
        ("Gratitude Practice", "Appreciating the present moment", 360),
        ("Integration & Next Steps", "Building a sustainable practice", 600)
    ]
    
    for (index, item) in beginnerSeries.enumerated() {
        content.append(ContentItem(
            id: "beginner_\(index + 1)",
            title: item.0,
            description: item.1,
            category: .meditation,
            subcategory: "Beginner Series",
            duration: TimeInterval(item.2),
            isPremium: true,
            audioFileName: "beginner_\(index + 1).mp3",
            instructionPhases: nil,
            tags: ["meditation", "beginner", "series"],
            difficulty: .beginner,
            createdDate: now,
            updatedDate: now
        ))
    }
    
    // Anxiety Management Series (Premium)
    let anxietySeries = [
        ("Understanding Anxiety", "Learn about anxiety and how meditation helps", 480),
        ("Panic Attack Recovery", "Techniques for after an anxiety episode", 300),
        ("Social Anxiety Relief", "Building confidence in social situations", 720),
        ("Work Stress Management", "Finding calm in professional challenges", 900),
        ("Future Worry Release", "Letting go of what hasn't happened yet", 600),
        ("Health Anxiety Support", "Managing worry about physical symptoms", 840),
        ("Perfectionism Release", "Embracing good enough", 660),
        ("Imposter Syndrome", "Recognizing your worth and abilities", 780),
        ("Decision-Making Clarity", "Finding wisdom in uncertainty", 540),
        ("Boundary Setting", "Protecting your energy and peace", 960),
        ("Self-Compassion Practice", "Being kind to yourself", 720),
        ("Anxiety Prevention Daily", "Building resilience for tomorrow", 420)
    ]
    
    for (index, item) in anxietySeries.enumerated() {
        content.append(ContentItem(
            id: "anxiety_\(index + 1)",
            title: item.0,
            description: item.1,
            category: .meditation,
            subcategory: "Anxiety Management",
            duration: TimeInterval(item.2),
            isPremium: true,
            audioFileName: "anxiety_\(index + 1).mp3",
            instructionPhases: nil,
            tags: ["meditation", "anxiety", "series", "featured"],
            difficulty: .intermediate,
            createdDate: now,
            updatedDate: now
        ))
    }
    
    // Mindful Rituals (Premium)
    content.append(ContentItem(
        id: "ritual_hot_chocolate",
        title: "Mindful Hot Chocolate",
        description: "Turn your favorite drink into a meditation",
        category: .ritual,
        subcategory: "Warm Drinks",
        duration: 1200, // 20 minutes
        isPremium: true,
        audioFileName: "hot_chocolate_guide.mp3",
        instructionPhases: nil,
        tags: ["ritual", "mindfulness", "comfort", "featured"],
        difficulty: .beginner,
        createdDate: now,
        updatedDate: now
    ))
    
    return content
}