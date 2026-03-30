//
//  OnboardingModels.swift
//  Mycountdown
//
//  Created by GetApple on 2/13/26.
//

import Foundation

// MARK: - Models

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let emoji: String?
    let image: OnboardingImage?
    let title: String
    let description: String
    let buttonTitle: String
}

enum OnboardingImage {
    case logo
    case onboarding1
    case onboarding2
}
