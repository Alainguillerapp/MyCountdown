//
//  StoreProduct.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 28.01.2026.
//

import Foundation
import RevenueCat

extension StoreProduct {

    func yearEquivalent() -> String {

        guard let period = subscriptionPeriod,
              period.unit == .year
        else {
            return localizedPriceString
        }

        let monthlyPrice = price / 12

        let number = NSDecimalNumber(decimal: monthlyPrice)

        let priceString = localizedPriceString

        let currencyPart = priceString
            .replacingOccurrences(
                of: "[0-9.,\\s]",
                with: "",
                options: .regularExpression
            )

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = priceFormatter?.locale

        let value = formatter.string(from: number) ?? "\(number)"

        if priceString.hasPrefix(currencyPart) {
            return "\(currencyPart)\(value)"
        } else {
            return "\(value) \(currencyPart)"
        }
    }
}
