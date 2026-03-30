//
//  PaywallGoPremiumData.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 2/13/26.
//

import Foundation
import SwiftUI

enum PaywallGoPremiumData {
    
    static let features: [Feature] = [
        .init(
            icon: .image(Image(.featureItem2)),
            title: "Unlock widgets".localized,
            subtitle: "Add counters to your Home Screen".localized
        ),
        .init(
            icon: .image(Image(.featureItem1)),
            title: "Add unlimited events".localized,
            subtitle: "Don't let yourself get overwhelmed".localized
        ),
        .init(
            icon: .image(Image(.featureItem3)),
            title: "Customize your counter".localized,
            subtitle: "Years, months, weeks, days".localized
        ),
        .init(
            icon: .image(Image(.featureItem4)),
            title: "Change counter information".localized,
            subtitle: "Real-time updates".localized
        ),
        .init(
            icon: .image(Image(.featureItem5)),
            title: "Import your data".localized,
            subtitle: "Changed your phone?".localized
        ),
        .init(
            icon: .emoji("❤️"),
            title: "Support creators".localized,
            subtitle: "We have big dreams for the app".localized
        )
    ]
}
