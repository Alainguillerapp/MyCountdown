//
//  StoreProduct.swift
//  Mycountdown
//
//  Created by GetApple on 28.01.2026.
//

import Foundation
import RevenueCat

extension StoreProduct {

    func yearEquivalent() -> String {

        guard let period = subscriptionPeriod,
              period.unit == .year else {
            return localizedPriceString
        }

        let yearPrice = price * Decimal(12)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        formatter.currencyCode = currencyCode
        
        formatter.locale = Locale(identifier: "en_US")

        return formatter.string(from: yearPrice as NSDecimalNumber)
        ?? localizedPriceString
    }
}
