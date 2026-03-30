//
//  PaywallGoPremiumModels.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 2/13/26.
//

import Foundation
import SwiftUI

// MARK: - Models

struct Feature: Identifiable {
    let id = UUID()
    let icon: FeatureIcon
    let title: String
    let subtitle: String
}

enum FeatureIcon {
    case image(Image)
    case emoji(String)
}

enum Plan {
    case year
    case week
    case lifetime
}
