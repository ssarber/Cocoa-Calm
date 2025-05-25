//
//  SubscriptionManager.swift
//  Cocoa Calm
//
//  Enhanced subscription management for premium platform
//

import Foundation
import StoreKit
import SwiftUI
import Combine

// MARK: - Subscription Models

enum SubscriptionTier: String, CaseIterable {
    case free = "free"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
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
        case .monthly: return "Save 38%"
        case .annual: return "Save 74%"
        case .lifetime: return "Best Value"
        }
    }
}

@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isSubscribed: Bool = false
    @Published var currentPlan: SubscriptionPlan? = nil
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var trialDaysRemaining: Int = 0
    @Published var isInTrialPeriod: Bool = false
    @Published var subscriptionExpiryDate: Date? = nil
    @Published var isLoading: Bool = false
    @Published var purchaseError: String? = nil
    
    // MARK: - Store Properties
    @Published var availableProducts: [Product] = []
    private var updateListenerTask: Task<Void, Error>? = nil
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Product IDs (matching our PRD pricing)
    private let productIDs: Set<String> = [
        "cocoa_calm_weekly",
        "cocoa_calm_monthly", 
        "cocoa_calm_annual",
        "cocoa_calm_lifetime"
    ]
    
    // MARK: - User Defaults Keys
    private let subscriptionStatusKey = "subscription_status"
    private let trialStartDateKey = "trial_start_date"
    private let lifetimePurchaseKey = "lifetime_purchase"
    
    // MARK: - Constants
    private let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    // MARK: - Initialization
    
    init() {
        // Start transaction listener
        updateListenerTask = listenForTransactions()
        
        // Load cached subscription status
        loadSubscriptionStatus()
        
        // Load products from App Store
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            isLoading = true
            let products = try await Product.products(for: productIDs)
            
            // Sort products by price (ascending)
            availableProducts = products.sorted { product1, product2 in
                product1.price < product2.price
            }
            
            isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            isLoading = false
        }
    }
    
    // MARK: - Purchase Functions
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        purchaseError = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Update subscription status
                await updateSubscriptionStatus(for: transaction)
                
                // Finish the transaction
                await transaction.finish()
                
                isLoading = false
                
            case .userCancelled:
                isLoading = false
                
            case .pending:
                isLoading = false
                
            @unknown default:
                isLoading = false
            }
        } catch {
            isLoading = false
            purchaseError = error.localizedDescription
            throw error
        }
    }
    
    func startFreeTrial() {
        guard !isInTrialPeriod && !isSubscribed else { return }
        
        let trialStartDate = Date()
        UserDefaults.standard.set(trialStartDate, forKey: trialStartDateKey)
        
        isInTrialPeriod = true
        subscriptionTier = .premium
        trialDaysRemaining = 7
        
        // Calculate trial expiry
        subscriptionExpiryDate = Calendar.current.date(byAdding: .day, value: 7, to: trialStartDate)
        
        saveSubscriptionStatus()
        
        // Schedule daily trial reminder checks
        scheduleTrialReminders()
    }
    
    func restorePurchases() async {
        isLoading = true
        
        try? await AppStore.sync()
        await checkSubscriptionStatus()
        
        isLoading = false
    }
    
    // MARK: - Subscription Status Management
    
    func checkSubscriptionStatus() async {
        var hasActiveSubscription = false
        var currentSubscription: SubscriptionPlan? = nil
        var expiryDate: Date? = nil
        
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let productID = SubscriptionPlan(rawValue: transaction.productID) {
                    hasActiveSubscription = true
                    currentSubscription = productID
                    expiryDate = transaction.expirationDate
                    
                    // Lifetime purchase doesn't expire
                    if productID == .lifetime {
                        expiryDate = nil
                        UserDefaults.standard.set(true, forKey: lifetimePurchaseKey)
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        // Update UI on main thread
        await MainActor.run {
            isSubscribed = hasActiveSubscription || hasLifetimePurchase()
            currentPlan = currentSubscription
            subscriptionExpiryDate = expiryDate
            subscriptionTier = isSubscribed ? .premium : .free
            
            // If no active subscription, check trial status
            if !isSubscribed {
                checkTrialStatus()
            } else {
                // Clear trial if user has active subscription
                isInTrialPeriod = false
                trialDaysRemaining = 0
            }
            
            saveSubscriptionStatus()
        }
    }
    
    private func updateSubscriptionStatus(for transaction: StoreKit.Transaction) async {
        guard let plan = SubscriptionPlan(rawValue: transaction.productID) else { return }
        
        await MainActor.run {
            isSubscribed = true
            currentPlan = plan
            subscriptionTier = .premium
            subscriptionExpiryDate = transaction.expirationDate
            
            // Clear trial status
            isInTrialPeriod = false
            trialDaysRemaining = 0
            
            // Handle lifetime purchase
            if plan == .lifetime {
                subscriptionExpiryDate = nil
                UserDefaults.standard.set(true, forKey: lifetimePurchaseKey)
            }
            
            saveSubscriptionStatus()
        }
    }
    
    private func checkTrialStatus() {
        guard let trialStartDate = UserDefaults.standard.object(forKey: trialStartDateKey) as? Date else {
            // No trial started
            isInTrialPeriod = false
            trialDaysRemaining = 0
            return
        }
        
        let now = Date()
        let trialEndDate = trialStartDate.addingTimeInterval(trialDuration)
        
        if now < trialEndDate {
            // Still in trial
            isInTrialPeriod = true
            subscriptionTier = .premium
            let daysRemaining = Calendar.current.dateComponents([.day], from: now, to: trialEndDate).day ?? 0
            trialDaysRemaining = max(0, daysRemaining)
            subscriptionExpiryDate = trialEndDate
        } else {
            // Trial expired
            isInTrialPeriod = false
            trialDaysRemaining = 0
            subscriptionTier = .free
            subscriptionExpiryDate = nil
        }
    }
    
    // MARK: - Helper Functions
    
    func hasActiveSubscription() -> Bool {
        return isSubscribed || isInTrialPeriod
    }
    
    func hasLifetimePurchase() -> Bool {
        return UserDefaults.standard.bool(forKey: lifetimePurchaseKey)
    }
    
    func canAccessPremiumContent() -> Bool {
        return hasActiveSubscription() || hasLifetimePurchase()
    }
    
    func getSubscriptionStatusText() -> String {
        if hasLifetimePurchase() {
            return "Lifetime Access"
        } else if isSubscribed {
            if let expiryDate = subscriptionExpiryDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Active until \(formatter.string(from: expiryDate))"
            } else {
                return "Active Subscription"
            }
        } else if isInTrialPeriod {
            return "\(trialDaysRemaining) days left in trial"
        } else {
            return "Free Plan"
        }
    }
    
    func getPrimaryProduct() -> Product? {
        // Return monthly as primary/recommended option
        return availableProducts.first { $0.id == SubscriptionPlan.monthly.rawValue }
    }
    
    // MARK: - Transaction Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateSubscriptionStatus(for: transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveSubscriptionStatus() {
        let status = [
            "isSubscribed": isSubscribed,
            "tier": subscriptionTier.rawValue,
            "isInTrial": isInTrialPeriod,
            "trialDaysRemaining": trialDaysRemaining
        ] as [String : Any]
        
        UserDefaults.standard.set(status, forKey: subscriptionStatusKey)
    }
    
    private func loadSubscriptionStatus() {
        guard let status = UserDefaults.standard.dictionary(forKey: subscriptionStatusKey) else { return }
        
        isSubscribed = status["isSubscribed"] as? Bool ?? false
        
        if let tierString = status["tier"] as? String {
            subscriptionTier = SubscriptionTier(rawValue: tierString) ?? .free
        }
        
        isInTrialPeriod = status["isInTrial"] as? Bool ?? false
        trialDaysRemaining = status["trialDaysRemaining"] as? Int ?? 0
    }
    
    // MARK: - Trial Reminders
    
    private func scheduleTrialReminders() {
        // Schedule notifications for days 2, 5, and 6 of trial
        // This would integrate with UNUserNotificationCenter
        // Implementation details would depend on notification preferences
    }
}

// MARK: - Subscription Errors

enum SubscriptionError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Failed to verify purchase"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}