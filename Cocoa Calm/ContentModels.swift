//
//  ContentModels.swift
//  Cocoa Calm
//
//  Content library models for meditation content
//

import Foundation

// MARK: - Content Library Models

class ContentItem: ObservableObject, Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var duration: TimeInterval
    var category: ContentCategory
    var subcategory: String?
    var isPremium: Bool
    var audioFileName: String?
    var imageFileName: String?
    var instructionPhases: [String]?
    var tags: [String]
    var difficulty: DifficultyLevel
    var createdDate: Date
    var updatedDate: Date
    
    enum DifficultyLevel: String, CaseIterable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        
        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            }
        }
    }
    
    enum ContentCategory: String, CaseIterable {
        case meditation = "meditation"
        case breathing = "breathing"
        case rituals = "rituals"
        case ritual = "ritual"
        case anxiety = "anxiety"
        case sleep = "sleep"
        case focus = "focus"
        case crisis = "crisis"
        
        var displayName: String {
            switch self {
            case .meditation: return "Meditation"
            case .breathing: return "Breathing"
            case .rituals: return "Rituals"
            case .ritual: return "Ritual"
            case .anxiety: return "Anxiety Relief"
            case .sleep: return "Sleep"
            case .focus: return "Focus"
            case .crisis: return "Crisis Support"
            }
        }
        
        var icon: String {
            switch self {
            case .meditation: return "leaf"
            case .breathing: return "wind"
            case .rituals: return "cup.and.saucer"
            case .ritual: return "cup.and.saucer"
            case .anxiety: return "heart"
            case .sleep: return "moon"
            case .focus: return "target"
            case .crisis: return "exclamationmark.shield"
            }
        }
    }
    
    init(id: String? = nil, title: String, description: String, category: ContentCategory, subcategory: String? = nil, duration: TimeInterval, isPremium: Bool = false, audioFileName: String? = nil, imageFileName: String? = nil, instructionPhases: [String]? = nil, tags: [String] = [], difficulty: DifficultyLevel = .beginner, createdDate: Date = Date(), updatedDate: Date = Date()) {
        self.title = title
        self.description = description
        self.duration = duration
        self.category = category
        self.subcategory = subcategory
        self.isPremium = isPremium
        self.audioFileName = audioFileName
        self.imageFileName = imageFileName
        self.instructionPhases = instructionPhases
        self.tags = tags
        self.difficulty = difficulty
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
}
