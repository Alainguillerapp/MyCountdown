//
//  Haptics.swift
//  Mycountdown
//
//  Created by GetApple on 19.01.2026.
//

import UIKit

enum Haptic {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
