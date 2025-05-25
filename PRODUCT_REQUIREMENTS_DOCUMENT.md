# Cocoa Calm - Product Requirements Document (PRD)

## 📋 Table of Contents
1. [Executive Summary](#executive-summary)
2. [Product Overview](#product-overview)
3. [Target Audience](#target-audience)
4. [Core Features](#core-features)
5. [Technical Requirements](#technical-requirements)
6. [User Experience Flow](#user-experience-flow)
7. [UI/UX Design Specifications](#uiux-design-specifications)
8. [Feature Specifications](#feature-specifications)
9. [Data Management](#data-management)
10. [Audio Requirements](#audio-requirements)
11. [Platform Requirements](#platform-requirements)
12. [Monetization & Premium Features](#monetization--premium-features)
13. [Development Phases](#development-phases)
14. [Quality Assurance](#quality-assurance)
15. [Success Metrics](#success-metrics)

## 📊 Executive Summary

**Product Name:** Cocoa Calm  
**Version:** 1.0  
**Platform:** iOS/macOS Universal (SwiftUI)  
**Target Launch:** Q2 2025  

Cocoa Calm is a mindfulness and anxiety management app that provides users with quick, accessible tools for finding moments of peace through meditation, breathing exercises, and mindful rituals. The app emphasizes simplicity, warmth, and immediate relief during anxious moments.

## 🎯 Product Overview

### Vision Statement
To provide instant, accessible mindfulness tools that help users manage anxiety and find calm in everyday moments through simple, guided experiences.

### Mission
Create a warm, intuitive digital companion that offers practical anxiety relief techniques, focusing on quick interventions and mindful practices that can be done anywhere, anytime.

### Core Value Proposition
- **Immediate Relief**: Quick access to anxiety management tools
- **Mindful Simplicity**: Clean, uncluttered interface that promotes calm
- **Practical Guidance**: Real-world activities like mindful hot chocolate preparation
- **Universal Access**: Cross-platform availability (iOS/macOS)

## 👥 Target Audience

### Primary Users
- **Anxiety Sufferers** (Ages 18-45): Individuals experiencing daily anxiety who need quick relief tools
- **Mindfulness Beginners**: People new to meditation seeking simple, guided experiences
- **Busy Professionals**: Those requiring brief, effective stress management during work

### Secondary Users
- **Students**: Managing academic stress and anxiety
- **Parents**: Seeking calm moments during busy family life
- **Healthcare Workers**: Requiring quick stress relief during demanding shifts

### User Personas

#### Sarah (Primary Persona)
- **Age**: 28, Marketing Professional
- **Goals**: Quick anxiety relief during workday, simple meditation practices
- **Pain Points**: Limited time, easily overwhelmed by complex apps
- **Technology**: iPhone user, values simplicity

#### David (Secondary Persona)
- **Age**: 35, Parent of two
- **Goals**: Find calm moments between family responsibilities
- **Pain Points**: Interruptions, needs flexible timing
- **Technology**: Uses both mobile and desktop

## ⚡ Core Features

### 1. **Emergency SOS Mode**
Quick access anxiety relief system with immediate intervention options.

### 2. **Guided Meditation Timer**
Simple meditation sessions with audio instructions and flexible timing.

### 3. **Breathing Exercises**
Animated breathing patterns with audio cues for immediate stress relief.

### 4. **Mindful Hot Chocolate Ritual**
Unique feature combining recipe guidance with mindfulness prompts.

### 5. **Audio Guide Experience**
Premium narrated experiences for deeper relaxation (with paywall).

### 6. **Onboarding Journey**
Welcoming introduction to app features and mindfulness concepts.

## 🔧 Technical Requirements

### Development Stack
- **Framework**: SwiftUI
- **Language**: Swift 5.0+
- **Audio**: AVFoundation
- **Data**: SwiftData
- **Architecture**: MVVM Pattern
- **State Management**: @State, @StateObject, @ObservableObject

### Minimum System Requirements
- **iOS**: 18.2+
- **macOS**: 14.0+
- **Storage**: 50MB base + audio files
- **Audio**: Speakers/headphones recommended

### Dependencies
- AVFoundation (audio playback)
- SwiftData (data persistence)
- Combine (reactive programming)
- CloudKit (future cloud sync)

## 🎨 User Experience Flow

### App Launch Flow
```
App Launch
    ↓
Onboarding Check
    ↓
[First Time] → Onboarding (3 screens) → Home
[Returning] → Home
```

### Emergency Flow
```
Home → "Feeling Anxious?" → SOS Modal
    ↓
Choose Relief Method:
    • Breathing Exercise → BreatheView
    • Quick Grounding → [Future Feature]
    • Mindful Sip Prep → Hot Chocolate Guide
```

### Regular Usage Flow
```
Home → Quick Actions
    ↓
Choose Activity:
    • Meditate → Timer + Audio Instructions
    • Hot Chocolate → Step-by-step Guide
    • HC Audio → Premium Audio Experience
    • Log Entry → [Future Feature]
```

## 🎨 UI/UX Design Specifications

### Design System

#### Color Palette
- **Primary Background**: Blue-purple gradient (opacity 0.1-0.2)
- **SOS Button**: Teal (opacity 0.8) - calming yet attention-grabbing
- **Action Buttons**: Context-appropriate colors (blue, brown, green)
- **Text**: Primary/secondary system colors for accessibility
- **Audio Background**: Warm brown gradient for hot chocolate theme

#### Typography
- **Main Title**: System font, 34pt, bold
- **Section Headers**: System font, title2, semibold
- **Body Text**: System font, body weight
- **Timer Display**: System font, 48pt, light, monospaced
- **Instructions**: System font, title2, medium

#### Iconography
- SF Symbols for consistency across Apple ecosystem
- Contextual icons (cup.and.saucer.fill, figure.mind.and.body, etc.)
- Clear, recognizable symbols for quick understanding

#### Layout Principles
- **Generous Spacing**: 20-40pt between major sections
- **Touch Targets**: Minimum 44pt for accessibility
- **Modal Presentation**: Full-screen sheets with navigation toolbars
- **Consistent Padding**: 20pt standard content padding

### Navigation Pattern
- **Modal-First**: All detailed views presented as modal sheets
- **Dismissal**: "×" buttons in top-trailing toolbar position
- **Navigation Bar**: Inline title style for clean appearance
- **Background Dismissal**: Disabled to prevent accidental closure

## 📋 Feature Specifications

### 1. Onboarding Experience

#### Requirements
- **3-Screen Flow**: Welcome → Features → Getting Started
- **Visual Elements**: SF Symbol icons, descriptive text
- **User Control**: Swipe navigation with page indicators
- **Completion Tracking**: Persistent storage of onboarding status

#### Content Structure
```
Screen 1: "Welcome to Cocoa Calm"
- Icon: sparkles
- Message: Companion for finding peace and managing anxiety

Screen 2: "Discover Quick Relief"
- Icon: figure.mind.and.body
- Message: Breathing exercises, mindful guides, meditation timers

Screen 3: "Ready to Begin?"
- Icon: checkmark.circle.fill
- Message: Explore and start your mindful journey
- Action: "Get Started" button
```

### 2. Home Screen

#### Layout Components
- **Greeting Section**: "Welcome" with personalized touch
- **Emergency Access**: Prominent "Feeling Anxious?" button
- **Quick Actions Grid**: 2x2 grid of primary features
- **Daily Quote**: Rotating inspirational message
- **Background**: Calming gradient

#### Quick Actions
1. **Meditate** - Opens guided meditation timer
2. **Hot Chocolate** - Opens recipe guide
3. **HC Audio** - Opens premium audio experience
4. **Log Entry** - Future journaling feature

### 3. SOS Emergency Mode

#### Trigger
Large, accessible button on home screen with calming teal color.

#### Options
1. **Breathe** - 3 inhales, 3 exhales pattern
2. **Quick Grounding** - Future sensory grounding exercise
3. **Mindful Sip Prep** - Hot chocolate preparation

#### Behavior
- Modal presentation with immediate dismissal
- Triggers secondary modals for chosen relief method
- No nested navigation - flat modal structure

### 4. Breathing Exercise (BreatheView)

#### Visual Design
- **Animated Circle**: Blue circle scaling from 1.0 to 1.5
- **Background**: Blue-purple gradient
- **Instructions**: Clear text prompts for each breath
- **Progress**: Repetition counter (Rep: X/Y format)

#### Animation Sequence
```
Quick Reset Pattern (3 in, 3 out):
1. Inhale 1 → Scale to 1.2 (0.165s)
2. Inhale 2 → Scale to 1.35 (0.165s)
3. Inhale 3 → Scale to 1.5 (0.165s)
4. Pause (1.0s)
5. Exhale 1 → Scale to 1.3 (0.22s)
6. Exhale 2 → Scale to 1.15 (0.22s)
7. Exhale 3 → Scale to 1.0 (0.22s)
8. Repeat for ~30 seconds total
```

#### Audio Integration
- **Sound Files**: inhale.wav, exhale.wav
- **Playback**: AVAudioPlayer with proper cleanup
- **Error Handling**: Graceful degradation if audio fails

### 5. Guided Meditation (MeditateView)

#### Session Structure
```
Phase-based instruction system:
1. Setup (10s): "Find comfortable position, close eyes"
2. Environmental Awareness (45s): "Listen to sounds around you"
3. Transition (15s): "Shift attention to space behind eyelids"
4. Core Practice (75s): "Rest attention here gently"
5. Guidance (75s): "When thoughts arise, acknowledge and return"
6. Continuation (60s): "Rest attention here gently"
7. Preparation (10s): "Session ending soon"
8. Completion (10s): "Bring awareness back, open eyes"
```

#### Technical Implementation
- **Timer**: Combine-based countdown with phase transitions
- **Audio Files**: instruction_0.mp3 through instruction_7.mp3
- **State Management**: Phase tracking, audio playback status
- **UI Elements**: Large monospaced timer, start/stop controls

### 6. Hot Chocolate Guide (HotChocolateGuideView)

#### Content Structure
1. **Header**: Icon + title "Mindful Hot Chocolate"
2. **Intro**: Mindfulness framing text
3. **Recipe Steps**: 5 numbered steps with mindful prompts
4. **Optional Actions**: Log ritual button (future feature)

#### Step Format
```
Each step contains:
- Step number (bold, brown color)
- Instruction text (primary)
- Mindful prompt (italic, secondary)

Example:
1. Pour half cup of almond milk into mug
   Notice the sound as it pours, the color and texture
```

#### Visual Design
- **Background**: Orange-brown gradient for warmth
- **Layout**: Scrollable VStack with generous spacing
- **Typography**: Clear hierarchy with step numbers

### 7. Premium Audio Experience (HotChocolateGuideAudioView)

#### Paywall System
- **Subscription Manager**: Observable class for subscription state
- **Paywall UI**: Modal presentation with trial offer
- **Content Gates**: Locked screen vs. full audio player

#### Audio Player Features
- **Background Animation**: Swirling brown circles during playback
- **Controls**: Large play/pause button, time display
- **Progress**: Current time / total duration
- **File**: hot_chocolate_guide.mp3

#### Subscription Flow
```
Initial Access → Check Subscription
    ↓
[Not Subscribed] → Paywall Modal
    ↓
Start Free Trial → Unlock Content
    ↓
[Subscribed] → Full Audio Player
```

## 💾 Data Management

### Persistence Requirements
- **Onboarding Status**: UserDefaults/AppStorage
- **Subscription State**: Keychain (future StoreKit integration)
- **Usage Analytics**: Core Data/SwiftData (future)
- **User Preferences**: UserDefaults

### Data Models
```swift
// Current
@Model class Item {
    var timestamp: Date
}

// Future Expansion
@Model class MeditationSession {
    var date: Date
    var duration: TimeInterval
    var type: SessionType
}

@Model class JournalEntry {
    var date: Date
    var content: String
    var mood: MoodLevel
}
```

## 🎵 Audio Requirements

### File Specifications
- **Format**: MP3/WAV
- **Quality**: 44.1kHz, 16-bit minimum
- **Size**: Optimized for mobile (< 5MB per file)

### Required Audio Files
1. **Breathing**: inhale.wav, exhale.wav
2. **Meditation**: instruction_0.mp3 through instruction_7.mp3
3. **Premium**: hot_chocolate_guide.mp3

### Audio Implementation
- **Player**: AVAudioPlayer for local files
- **Session Management**: Proper audio session handling
- **Background**: Audio continues in background for meditation
- **Cleanup**: Stop playback on view dismissal

## 🖥️ Platform Requirements

### Universal App Features
- **iOS**: Primary platform with touch interface
- **macOS**: Full feature parity with mouse/keyboard
- **Responsive**: Adaptive layouts for different screen sizes
- **Accessibility**: VoiceOver support, Dynamic Type

### Platform-Specific Considerations
- **iOS**: Background audio permissions, notification support
- **macOS**: Window management, menu bar integration
- **Shared**: CloudKit sync for cross-device continuity

## 💰 Monetization & Premium Features

### Freemium Model
- **Free Tier**: Basic meditation, breathing exercises, recipe guide
- **Premium Tier**: Audio guides, extended sessions, advanced features

### Premium Features (Future)
- **Audio Library**: Extended guided meditations
- **Personalization**: Custom session lengths, themes
- **Analytics**: Progress tracking, insights
- **Cloud Sync**: Cross-device synchronization

### Subscription Implementation
- **StoreKit**: Native iOS/macOS purchase flow
- **Free Trial**: 7-day trial period
- **Pricing**: $4.99/month or $29.99/year

## 🚀 Development Phases

### Phase 1: MVP (Current State)
- ✅ Onboarding flow
- ✅ Home screen with navigation
- ✅ SOS emergency mode
- ✅ Breathing exercise
- ✅ Basic meditation timer
- ✅ Hot chocolate guide
- ✅ Premium audio framework

### Phase 2: Enhanced Features
- [ ] Audio file integration
- [ ] Subscription system (StoreKit)
- [ ] Usage analytics
- [ ] Settings screen
- [ ] Accessibility improvements

### Phase 3: Advanced Features
- [ ] Journaling system
- [ ] Progress tracking
- [ ] Customizable sessions
- [ ] Cloud synchronization
- [ ] Notification reminders

### Phase 4: Platform Expansion
- [ ] Apple Watch companion
- [ ] Widget support
- [ ] macOS optimization
- [ ] iPad-specific layouts

## 🧪 Quality Assurance

### Testing Strategy
- **Unit Tests**: Core logic, data models
- **UI Tests**: Navigation flows, modal presentations
- **Audio Tests**: Playback reliability, error handling
- **Accessibility Tests**: VoiceOver, Dynamic Type
- **Performance**: Memory usage, battery impact

### Device Testing
- **iOS**: iPhone 12 Mini to iPhone 15 Pro Max
- **macOS**: Intel and Apple Silicon Macs
- **Accessibility**: Physical motor limitations, visual impairments

### Quality Metrics
- **Crash Rate**: < 0.1%
- **App Store Rating**: > 4.5 stars
- **Performance**: < 3 second launch time
- **Accessibility**: WCAG 2.1 AA compliance

## 📊 Success Metrics

### User Engagement
- **Daily Active Users**: Target 70% of monthly users
- **Session Duration**: Average 5-10 minutes
- **Feature Usage**: 80% try SOS mode within first week
- **Retention**: 60% return after 30 days

### Business Metrics
- **Conversion Rate**: 15% free to premium
- **Subscription Retention**: 80% monthly renewal
- **App Store**: Featured in Health & Fitness category
- **User Reviews**: Maintain 4.5+ rating

### Wellness Impact
- **User Reports**: Qualitative feedback on anxiety reduction
- **Usage Patterns**: Consistent daily engagement
- **Feature Effectiveness**: High completion rates for exercises

## 📚 Technical Documentation

### Code Architecture
```
CocoaCalm/
├── App/
│   ├── Cocoa_CalmApp.swift (Entry point)
│   └── ContentView.swift (Main navigation)
├── Views/
│   ├── OnboardingView.swift
│   ├── MeditateView.swift
│   ├── BreatheView.swift
│   ├── HotChocolateGuideView.swift
│   └── HotChocolateGuideAudioView.swift
├── Models/
│   ├── Item.swift (SwiftData)
│   └── SubscriptionManager.swift
├── Resources/
│   ├── Audio/
│   └── Assets.xcassets
└── Supporting Files/
    ├── Info.plist
    └── Entitlements
```

### Key Implementation Notes
- **Modal Navigation**: All detail views use sheet presentation
- **State Management**: Binding-based communication between views
- **Audio Handling**: AVAudioPlayer with proper lifecycle management
- **Error Handling**: Graceful degradation for missing audio files
- **Accessibility**: Native SwiftUI accessibility support

---

## 📝 Appendix

### Development Resources
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [AVFoundation Guide](https://developer.apple.com/documentation/avfoundation)
- [StoreKit Implementation](https://developer.apple.com/documentation/storekit)
- [Accessibility Guidelines](https://developer.apple.com/accessibility/)

### Design Resources
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols Library](https://developer.apple.com/sf-symbols/)
- [Color Guidelines](https://developer.apple.com/design/human-interface-guidelines/color)

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Next Review**: Q1 2025  

This PRD serves as the complete specification for implementing Cocoa Calm as an independent project. All current features are documented with technical details, user flows, and implementation guidance for a development team to recreate the application from scratch.
