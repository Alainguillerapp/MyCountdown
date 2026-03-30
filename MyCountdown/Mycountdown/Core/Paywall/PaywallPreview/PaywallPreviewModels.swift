//
//  PaywallPreviewModels.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 2/13/26.
//

import Foundation

// MARK: - Models

struct ItemFeatures: Identifiable {
    let id = UUID()
    let imageName: FeatureListIcon
    let text: String
}

enum FeatureListIcon: String {
    case featureItem1
    case featureItem2
    case featureItem3
    case featureItem4
    case featureItem5
}
