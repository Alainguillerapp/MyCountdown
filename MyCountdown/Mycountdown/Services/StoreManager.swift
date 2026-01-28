//
//  StoreManager.swift
//  Mycountdown
//
//  Created by Michael on 11/17/25.
//

import Foundation
import RevenueCat

@MainActor
final class StoreManager: NSObject, ObservableObject {
    
    @Published private(set) var premiumUnlocked: Bool = false
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var weeklyPackage: Package?
    @Published private(set) var yearlyPackage: Package?
    @Published private(set) var lifetimePackage: Package?
    @Published var purchaseInProgress = false
    
    private let entitlementID = "premium"
    private let appGroupID = "group.com.aliang"
    private let premiumKey = "isPremium"
    
    override init() {
        super.init()
        Purchases.shared.delegate = self
        checkPremiumOnLaunch()
        loadOfferings()
    }
    
    func checkPremiumOnLaunch() {
        Purchases.shared.getCustomerInfo { [weak self] info, _ in
            self?.updatePremium(from: info)
        }
    }
    
    private func updatePremium(from info: CustomerInfo?) {
        let isPro = info?.entitlements[entitlementID]?.isActive == true
        
        Task { @MainActor in
            premiumUnlocked = isPro
            
            UserDefaults(suiteName: appGroupID)?
                .set(isPro, forKey: premiumKey)
        }
    }
    
    func refreshCustomInfo() {
        Task { @MainActor in
            isLoading = true
        }
        
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            guard let self else { return }
            
            let isPro =
            info?.entitlements[self.entitlementID]?.isActive == true
            
            Task { @MainActor in
                self.premiumUnlocked = isPro
                self.isLoading = false
                self.saveProStatusToStorage(isPro)
            }
        }
    }
    
    func loadOfferings() {
        Purchases.shared.getOfferings { [weak self] offerings, error in

            guard let self else { return }
            guard let offering = offerings?.current else {
                print("❌ No current offering")
                return
            }

            self.weeklyPackage = offering.weekly
            self.yearlyPackage = offering.annual
            self.lifetimePackage = offering.lifetime

            print("✅ Packages loaded:")
            print("Weekly:", offering.weekly as Any)
            print("Yearly:", offering.annual as Any)
            print("Lifetime:", offering.lifetime as Any)
        }
    }
    
    //MARK: - Purchase
    func purchase(package: Package) async throws {
        
        await MainActor.run {
            purchaseInProgress = true
        }
        
        let result = try await Purchases.shared.purchase(package: package)
        
        let isPro = result.customerInfo.entitlements[entitlementID]?.isActive == true
        
        await MainActor.run {
            purchaseInProgress = false
            premiumUnlocked = isPro
            saveProStatusToStorage(isPro)
        }
    }
    
    //MARK: - Restore
    func restorePurchases() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            let isPro = info.entitlements[entitlementID]?.isActive == true
            
            await MainActor.run {
                premiumUnlocked = isPro
                saveProStatusToStorage(isPro)
            }
        } catch {
            print("❌ Restore failed", error)
        }
    }
    
    //MARK: - Storage (Widget support)
    private func saveProStatusToStorage(_ isPro: Bool) {
        UserDefaults(suiteName: appGroupID)?
            .set(isPro, forKey: premiumKey)
    }
}

extension StoreManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.updatePremium(from: customerInfo)
        }
    }
}
