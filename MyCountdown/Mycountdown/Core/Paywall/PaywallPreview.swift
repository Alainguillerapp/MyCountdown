//
//  PaywallSlides.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 12.01.2026.
//

import SwiftUI

import SwiftUI

struct PaywallPreview: View {

    @State private var currentIndex = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let onFinish: () -> Void

    private let features: [ItemFeatures] = [
        .init(imageName: .featureItem1, text: "Add unlimited events".localized),
        .init(imageName: .featureItem2, text: "Unlock widgets".localized),
        .init(imageName: .featureItem3, text: "Customize your counter".localized),
        .init(imageName: .featureItem4, text: "Change counter information".localized),
        .init(imageName: .featureItem5, text: "Import your data".localized)
    ]

    private let buttonTitles = [
        "TRY IT FOR FREE 🙌".localized,
        "TRY IT FOR FREE 🙌".localized,
        "START AN EVENT NOW".localized
    ]

    var body: some View {
        ZStack {

            BlurCustomBackground()

            VStack(spacing: 10) {

                header

                TabView(selection: $currentIndex) {
                    ForEach(0..<3, id: \.self) { index in
                        slideView(for: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                bottomControls
            }
        }
    }
}

// MARK: - Header

extension PaywallPreview {

    private var header: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// MARK: - Slides

extension PaywallPreview {

    private func slideView(for index: Int) -> some View {

        VStack(spacing: 25) {

            switch index {

            case 0:
                Image(.myCountdownLaunch)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)

                Group {
                    Text("Becomes ".localized).foregroundStyle(.black)
                    + Text("7x more efficient".localized).foregroundStyle(.proYellow)
                    + Text("\nand never forgets an event".localized).foregroundStyle(.black)
                }
                .font(.custom("PTSans-Bold", size: 26))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

                featuresList
                    .padding(.top, 12)

            case 1:
                Text("🎁")
                    .font(.system(size: 110))

                Group {
                    Text("We're offering you\n".localized).foregroundStyle(.black)
                    + Text("3 free days\n".localized).foregroundStyle(.proYellow)
                    + Text("to try MyCountdown Pro".localized).foregroundStyle(.black)
                }
                .font(.custom("PTSans-Bold", size: 26))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            case 2:
                Text("🔔")
                    .font(.system(size: 110))

                Group {
                    Text("We'll ".localized).foregroundStyle(.black)
                    + Text("call you back\n".localized).foregroundStyle(.proYellow)
                    + Text("one day before\n".localized).foregroundStyle(.black)
                    + Text("the end of your trial".localized).foregroundStyle(.black)
                }
                .font(.custom("PTSans-Bold", size: 26))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            default:
                EmptyView()
            }

            if index == 0 {
                Spacer()
            }
        }
    }
}

// MARK: - Bottom Controls

extension PaywallPreview {

    private var bottomControls: some View {
        GradientButton(
            title: buttonTitles[currentIndex],
            subtitle: currentIndex == 2 ? "🔔 Call me back in 2 days".localized : nil,
        ) {
            Haptic.impact(.light)
            
            withAnimation {
                if currentIndex < 2 {
                    currentIndex += 1
                } else {
                    onFinish()
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
    }
}

// MARK: - Features List

extension PaywallPreview {

    private var featuresList: some View {
        VStack(spacing: 16) {
            ForEach(features) { item in
                HStack(spacing: 14) {

                    Image(item.imageName.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text(item.text)
                        .font(.custom("PTSans-Bold", size: 16))
                        .foregroundStyle(.black)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 260, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

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

#Preview {
    PaywallPreview(onFinish: {})
}
