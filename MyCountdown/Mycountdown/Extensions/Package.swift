//
//  Package.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 22.01.2026.
//

import Foundation
import RevenueCat

extension Package {
    var localizedPrice: String {
        storeProduct.localizedPriceString
    }
    
    var subscriptionPeriod: String {
        guard let period = storeProduct.subscriptionPeriod else { return "" }
        
        switch period.unit {
        case .day: return "\(period.value) day"
        case .week: return "\(period.value) week"
        case .month: return "\(period.value) month"
        case .year: return "\(period.value) year"
        @unknown default: return ""
        }
    }
}
