//
//  OnboardingView.swift
//  Mycountdown
//
//  Created by GetApple on 30.12.2025.
//

import SwiftUI
import UIKit

struct OnboardingView: View {
    
    let onFinish: () -> Void
    @State private var currentIndex = 0
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false
    
    let slides: [OnboardingSlide] = [
        // 1 — Congratulations (logo + text)
        .init(
            emoji: nil,
            image: .logo,
            title: "congratulations".localized,
            description: "start_planning".localized,
            buttonTitle: "get_started".localized
        ),
        
        // 2 — In 2 minutes
        .init(
            emoji: nil,
            image: nil,
            title: "two_minutes_value".localized,
            description: "",
            buttonTitle: "next".localized
        ),
        
        // 3 — Your Events (Anna’s Birthday cards)
        .init(
            emoji: nil,
            image: .onboarding1,
            title: "your_events".localized,
            description: "no_limits".localized,
            buttonTitle: "next".localized
        ),
        
        // 4 — No stress (bell image)
        .init(
            emoji: nil,
            image: .onboarding2,
            title: "no_stress".localized,
            description: "event_notifications".localized,
            buttonTitle: "next".localized
        ),
        
        // 5 — Gain Serenity
        .init(
            emoji: "🎯",
            image: nil,
            title: "gain_serenity".localized,
            description: "full_control".localized,
            buttonTitle: "next".localized
        ),
        
        // 6 — Like a game (App Store image)
        .init(
            emoji: nil,
            image: nil,
            title: "",
            description: "user_quote".localized,
            buttonTitle: "lets_begin".localized
        )
    ]
    
    var body: some View {
        VStack(spacing: 13) {
            
            ZStack {
                Image(colorScheme == .dark ? .myCountdownLaunchWhite : .myCountdownLaunch)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 144, height: 144)
                    .opacity(currentIndex == 0 ? 0 : 1)
                    .animation(.easeInOut(duration: 0.35), value: currentIndex)

            }
            .frame(height: 184)
            .padding(.top, 40)
            .transaction { tx in
                tx.animation = nil
            }
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
            
            TabView(selection: $currentIndex) {
                ForEach(slides.indices, id: \.self) { index in
                    slideView(slides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .offset(y: currentIndex == 0 ? -60 : 0)
            
            
            Spacer()
            
            bottomControls
                .frame(height: 100)
            
        }
        .background(Color.clear)
    }
    
    private func slideImage(_ type: OnboardingImage) -> Image {
        switch type {
        case .logo:
            Image(colorScheme == .dark ? .myCountdownLaunchWhite : .myCountdownLaunch)
        case .onboarding1:
            Image(.onboardingImage1)
        case .onboarding2:
            Image(.onboardingImage2)
        }
    }
    
    private func slideView(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 20) {
            
            if let emoji = slide.emoji {
                Text(emoji)
                    .font(.system(size: 140))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .padding(.bottom, 30)
                    .padding(.leading, 24)
            }
            
            if let imageType = slide.image {
                
                let isFisrt = currentIndex == 0
                let isFourth = imageType == .onboarding2
                slideImage(imageType)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: isFisrt ? 154 : isFourth ? 190 : 220)
                    .padding(.vertical, currentIndex == 0 ? 20 : 10)
                    .padding(.top, currentIndex == 0 ? -60 : 0)
            }
            
            if slide.title.isEmpty {
                AppStoreRatingSection(rating: 4.6)
                    .padding(.bottom, 20)
            }
            
            if !slide.title.isEmpty {
                Text(slide.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, currentIndex == 0 ? 40 : 0)
            }
            
            Text(slide.description)
                .font(
                    slide.title.isEmpty
                    ? .system(size: 30, weight: .regular).italic()
                    : .system(size: 17)
                )
//                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.horizontal)
    }
}
#Preview {
    OnboardingView(onFinish: {})
}

extension OnboardingView {
    
    private var bottomControls: some View {
        VStack(spacing: 20) {
            
            HStack(spacing: 8) {
                ForEach(slides.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex
                              ? Color.primary
                              : Color.primary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .opacity(currentIndex == 0 ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
            
            GradientButton(title: slides[currentIndex].buttonTitle) {
                
                Haptic.impact(.light)
                
                withAnimation {
                    if currentIndex < slides.count - 1 {
                        currentIndex += 1
                    } else {
                        onFinish()
                    }
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 20)
    }
}

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
