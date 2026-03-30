//
//  PaywallPlanRow.swift
//  Mycountdown
//
//  Created by GetApple on 14.01.2026.
//

import SwiftUI

struct PaywallPlanRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let subtitle: String
    let price: String
    let duration: String
    let isSelected: Bool
    let hasTrial: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {

                selectionIndicator

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                priceText
            }
            .padding(6)
            .background(rowBackground)
            .overlay(rowBorder)
            .clipShape(Capsule())
            .overlay(alignment: .top) {
                if hasTrial {
                    PaywallBadge(text: "FREE TRIAL ⸱ SAVE 89%".localized)
                        .offset(y: -20)
                        .transition(badgeTransition)
                        .zIndex(10)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    var rowBackground: some View {
        ZStack {
            if isSelected {
                Color.borderPurple
            } else {
                Color.gray
            }
            
            SlantedRightShape(slant: 22)
                .fill(isSelected ? Color.white.opacity(0.9) : Color.gray.opacity(0.5))
                .frame(width: 120)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    var rowBorder: some View {
        Capsule()
            .stroke(
                isSelected ? .borderPurple : .gray,
                lineWidth: isSelected ? 3 : 0
            )
    }
    
    private var priceText: some View {
        VStack(spacing: 0) {
            Text(price)
                .font(.subheadline)
            
            Text(duration)
                .font(.system(size: 12))
        }
        .foregroundStyle(isSelected ? .borderPurple : .white)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }
    
    private var badgeTransition: AnyTransition {
        .asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity )
    }
    
    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 22, height: 22)

            if isSelected {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 22, height: 22)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.leading, 10)
    }
}

private extension PaywallPlanRow {

    var background: some View {
        ZStack {
            Color.white.opacity(isSelected ? 0.9 : 0.4)

            if isSelected {
                SlantedRightShape()
                    .fill(.borderPurple)
                    .frame(width: 120)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .clipShape(Capsule())
    }

    var border: some View {
        Capsule()
            .stroke(
                isSelected ? .borderPurple : Color.clear,
                lineWidth: 3
            )
    }
}
