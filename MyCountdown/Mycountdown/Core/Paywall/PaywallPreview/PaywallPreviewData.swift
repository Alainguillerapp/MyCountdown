//
//  PaywallPreviewData.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 2/13/26.
//

import Foundation

enum PaywallPreviewData {
    
    static let features: [ItemFeatures] = [
        .init(imageName: .featureItem2, text: "Unlock widgets".localized),
        .init(imageName: .featureItem1, text: "Add unlimited events".localized),
        .init(imageName: .featureItem3, text: "Customize your counter".localized),
        .init(imageName: .featureItem4, text: "Change counter information".localized),
        .init(imageName: .featureItem5, text: "Import your data".localized)
    ]

    static let buttonTitles = [
        "TRY IT FOR FREE 🙌".localized,
        "TRY IT FOR FREE 🙌".localized,
        "START AN EVENT NOW".localized
    ]
}

