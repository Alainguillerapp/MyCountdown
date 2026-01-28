//
//  StarRatingView.swift
//  Mycountdown
//
//  Created by GetApple on 05.01.2026.
//

import SwiftUI

struct StarRatingView: View {

    let rating: Double               // 0...5
    private let maxRating: Double = 5
    private let starSize: CGFloat = 22
    private let spacing: CGFloat = 6

    var body: some View {
        let clamped = min(max(rating, 0), maxRating)

        let fullStars = Int(clamped)
        let remainder = clamped - Double(fullStars)

        let visualRemainder = remainder > 0.75 ? 0.75 : remainder

        let totalWidth = starSize * CGFloat(maxRating) + spacing * CGFloat(maxRating - 1)

        return HStack(spacing: spacing) {
            ForEach(0..<Int(maxRating), id: \.self) { index in
                if index < fullStars {
                    filledStar
                } else if index == fullStars, remainder > 0 {
                    partialStar(fill: CGFloat(visualRemainder))
                } else {
                    emptyStar
                }
            }
        }
        .frame(width: totalWidth, height: starSize, alignment: .leading)
        .accessibilityLabel("Rating \(clamped, specifier: "%.1f") out of 5")
    }
    
    private var emptyStar: some View {
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .frame(width: starSize, height: starSize)
            .foregroundStyle(.gray.opacity(0.25))
            .overlay(outlineStar)
    }

    private var filledStar: some View {
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .frame(width: starSize, height: starSize)
            .foregroundStyle(.yellow)
            .overlay(outlineStar)
    }

    private var outlineStar: some View {
        Image(systemName: "star")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.black)
    }

    private func partialStar(fill: CGFloat) -> some View {
        ZStack {
            emptyStar

            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: starSize, height: starSize)
                .foregroundStyle(.yellow)
                .mask(
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: starSize * fill)
                        Spacer(minLength: 0)
                    }
                )
                .overlay(outlineStar)
        }
    }
}
