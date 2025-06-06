//
//  ProgressView.swift
//  Cocoa Calm
//
//  User progress tracking and analytics for meditation practice
//

import SwiftUI
import Charts

// MARK: - Supporting Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Double
}

struct UserProgressView: View {
    @EnvironmentObject var contentManager: ContentManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTimeframe: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header with current streak
                    headerSection
                    
                    // Key metrics cards
                    metricsSection
                    
                    // Weekly activity chart (Premium only)
                    if subscriptionManager.canAccessPremiumContent() {
                        activityChartSection
                    } else {
                        premiumChartLockedSection
                    }
                    
                    // Category breakdown
                    categoryBreakdownSection
                    
                    // Recent sessions
                    recentSessionsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .navigationTitle("Your Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Current streak
            VStack(spacing: 8) {
                Text("Current Streak")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    Text("\(contentManager.userProgress.currentStreak)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("days")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            
            // Motivational message
            Text(getMotivationalMessage())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .italic()
        }
    }
    
    // MARK: - Metrics Section
    
    private var metricsSection: some View {
        VStack(spacing: 16) {
            Text("Your Journey")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                
                MetricCard(
                    icon: "brain.head.profile",
                    title: "Total Sessions",
                    value: "\(contentManager.userProgress.totalSessions)",
                    subtitle: "meditations completed",
                    color: .blue
                )
                
                MetricCard(
                    icon: "clock.fill",
                    title: "Minutes Practiced",
                    value: String(format: "%.0f", contentManager.userProgress.totalMinutesMeditated),
                    subtitle: "total meditation time",
                    color: .green
                )
                
                MetricCard(
                    icon: "trophy.fill",
                    title: "Longest Streak",
                    value: "\(contentManager.userProgress.longestStreak)",
                    subtitle: "consecutive days",
                    color: .orange
                )
                
                MetricCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Avg. Session",
                    value: String(format: "%.1f min", averageSessionLength()),
                    subtitle: "typical practice",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Activity Chart Section
    
    private var activityChartSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Activity Overview")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
            
            if #available(iOS 16.0, *) {
                Chart(getChartData()) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Minutes", data.minutes)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            } else {
                // Fallback for older iOS versions
                VStack {
                    Text("Activity Chart")
                        .font(.headline)
                    Text("Available on iOS 16+")
                        .foregroundColor(.secondary)
                    
                    // Simple bar representation
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(getChartData().prefix(7)) { data in
                            VStack {
                                Rectangle()
                                    .fill(.blue.gradient)
                                    .frame(width: 20, height: CGFloat(data.minutes * 2))
                                    .cornerRadius(2)
                                
                                Text(data.day)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 200)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Premium Chart Locked Section
    
    private var premiumChartLockedSection: some View {
        VStack(spacing: 16) {
            Text("Activity Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue.opacity(0.3))
                
                VStack(spacing: 8) {
                    Text("Detailed Analytics")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Unlock detailed charts and progress insights with Premium")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    // Show premium paywall
                } label: {
                    Text("Upgrade to Premium")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.blue.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Category Breakdown Section
    
    private var categoryBreakdownSection: some View {
        VStack(spacing: 16) {
            Text("Favorite Categories")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if contentManager.userProgress.favoriteCategories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.pink)
                    
                    Text("Start meditating to see your preferences!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(contentManager.userProgress.favoriteCategories.enumerated()), id: \.offset) { index, category in
                        CategoryRankRow(
                            category: category,
                            rank: index + 1,
                            sessions: sessionCountForCategory(category)
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Recent Sessions Section
    
    private var recentSessionsSection: some View {
        VStack(spacing: 16) {
            Text("Recent Sessions")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if contentManager.userProgress.completedSessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("Your meditation history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(contentManager.userProgress.completedSessions.suffix(5).reversed()), id: \.id) { session in
                        SessionRow(session: session)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getMotivationalMessage() -> String {
        let streak = contentManager.userProgress.currentStreak
        let totalSessions = contentManager.userProgress.totalSessions
        
        if streak == 0 {
            return "Every journey begins with a single step. Start your practice today!"
        } else if streak == 1 {
            return "Great start! One day closer to a healthier mind."
        } else if streak < 7 {
            return "Building momentum! Keep your streak alive."
        } else if streak < 30 {
            return "Amazing consistency! You're developing a strong practice."
        } else {
            return "Incredible dedication! You're a meditation master."
        }
    }
    
    private func averageSessionLength() -> Double {
        guard !contentManager.userProgress.completedSessions.isEmpty else { return 0 }
        
        let totalMinutes = contentManager.userProgress.completedSessions
            .reduce(0) { $0 + ($1.completedDuration / 60) }
        
        return totalMinutes / Double(contentManager.userProgress.completedSessions.count)
    }
    
    private func sessionCountForCategory(_ category: ContentItem.ContentCategory) -> Int {
        return contentManager.userProgress.completedSessions
            .filter { $0.category == category }
            .count
    }
    
    private func getChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeframe.days, to: endDate) ?? endDate
        
        var data: [ChartDataPoint] = []
        
        for i in 0..<selectedTimeframe.days {
            let date = calendar.date(byAdding: .day, value: i - selectedTimeframe.days + 1, to: endDate) ?? endDate
            let dayName = DateFormatter().string(from: date)
            
            let sessionsForDay = contentManager.userProgress.completedSessions.filter {
                calendar.isDate($0.startTime, inSameDayAs: date)
            }
            
            let minutesForDay = sessionsForDay.reduce(0) { $0 + ($1.completedDuration / 60) }
            
            let formatter = DateFormatter()
            formatter.dateFormat = selectedTimeframe == .week ? "E" : "MM/dd"
            
            data.append(ChartDataPoint(day: formatter.string(from: date), minutes: minutesForDay))
        }
        
        return data
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct CategoryRankRow: View {
    let category: ContentItem.ContentCategory
    let rank: Int
    let sessions: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(rankColor)
                .cornerRadius(12)
            
            // Category icon
            Image(systemName: category.categoryIcon)
                .font(.title3)
                .foregroundColor(category.color)
                .frame(width: 24)
            
            // Category info
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(sessions) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

struct SessionRow: View {
    let session: MeditationSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: session.category.categoryIcon)
                .font(.title3)
                .foregroundColor(session.category.color)
                .frame(width: 24)
            
            // Session info
            VStack(alignment: .leading, spacing: 2) {
                if let content = ContentManager().getContentById(session.contentId) {
                    Text(content.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                } else {
                    Text("Meditation Session")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 8) {
                    Text(formatDate(session.startTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(session.completedDuration / 60)) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Completion indicator
            if session.wasCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - ContentCategory Extensions

extension ContentItem.ContentCategory {
    var categoryIcon: String {
        switch self {
        case .meditation: return "brain.head.profile"
        case .breathing: return "lungs.fill"
        case .sleep: return "moon.fill"
        case .anxiety: return "heart.circle"
        case .focus: return "target"
        case .ritual: return "cup.and.saucer.fill"
        case .rituals: return "cup.and.saucer.fill"
        case .crisis: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .meditation: return .blue
        case .breathing: return .mint
        case .sleep: return .indigo
        case .anxiety: return .green
        case .focus: return .orange
        case .ritual: return .brown
        case .rituals: return .brown
        case .crisis: return .red
        }
    }
}

// MARK: - Preview

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        UserProgressView()
            .environmentObject(ContentManager())
            .environmentObject(SubscriptionManager())
    }
}
