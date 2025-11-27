//
//  StoreManager.swift
//  Mycountdown
//
//  Created by Michael on 11/17/25.
//

import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
  
  @Published var premiumUnlocked: Bool = false
  @Published var product: Product?
  
  private let productID = "com.aliang.premium"
  private let premiumKey = "isPremium"
  
  private var appGroupDefaults: UserDefaults? {
      UserDefaults(suiteName: "group.com.aliang")
  }
  
  init() {
    Task {
      loadPremiumStatusFromStorage()
      await fetchProduct()
      await checkEntitlement()
      await observeTransactions()
    }
  }
  
  // MARK: - Public setter (if needed)
  func setPremiumStatus(_ isPremium: Bool) {
      premiumUnlocked = isPremium
      appGroupDefaults?.set(isPremium, forKey: premiumKey)
  }
  
  // MARK: - Fetch product
  func fetchProduct() async {
    do {
      let products = try await Product.products(for: [productID])
      product = products.first
    } catch {
      print("❌ Failed to fetch product:", error)
    }
  }
  
  // MARK: - Buy premium
  func buyPremium() async {
    guard let product else {
      print("❌ No product loaded")
      return
    }
    
    do {
      let result = try await product.purchase()
      
      switch result {
      case .success(let verification):
        switch verification {
        case .verified(let transaction):
          unlockPremium()
          await transaction.finish()
          print("🎉 Premium purchased and transaction finished")
          
        case .unverified(_, let error):
          print("⚠️ Purchase unverified:", error)
        }
        
      case .userCancelled:
        print("ℹ️ Purchase cancelled")
        
      case .pending:
        print("ℹ️ Purchase pending")
        
      @unknown default:
        print("⚠️ Unknown purchase result")
      }
      
    } catch {
      print("❌ Purchase failed:", error)
    }
  }
  
  // MARK: - Observe transactions
  func observeTransactions() async {
      for await result in Transaction.updates {
          switch result {
          case .verified(let transaction):
              if transaction.productID == productID {
                unlockPremium()
              }
              await transaction.finish()

          case .unverified(_, let error):
              print("⚠️ Unverified transaction:", error)
          }
      }
  }
  
  // MARK: - Restore purchases
  func restore() async {
    do {
      try await AppStore.sync()
      await checkEntitlement()
      print("🔄 Restore complete")
    } catch {
      print("❌ Restore failed:", error)
    }
  }
  
  func checkEntitlement() async {
    var owned = false
    
    for await result in Transaction.currentEntitlements {
      switch result {
      case .verified(let transaction):
        if transaction.productID == productID {
          owned = true
          unlockPremium()
          print("🔐 Premium entitlement verified")
        }
        
      case .unverified(_, let error):
        print("⚠️ Unverified transaction:", error)
      }
    }
    
    if !owned {
      premiumUnlocked = UserDefaults.standard.bool(forKey: premiumKey)
    }
  }
  
  // MARK: - Unlock & Save
  private func unlockPremium() {
    premiumUnlocked = true
    appGroupDefaults?.set(true, forKey: premiumKey)
  }
  
  private func loadPremiumStatusFromStorage() {
    premiumUnlocked = appGroupDefaults?.bool(forKey: premiumKey) ?? false
  }
}
