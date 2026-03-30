//
//  BlurCustomBackground.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 12.01.2026.
//

import SwiftUI

struct BlurCustomBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {

                // Base white
                Color.white

                // 🔵 Blue blob (top right - lowered + blur -10%)
                Circle()
                    .fill(
                        Color(red: 0.40, green: 0.75, blue: 0.95)
                            .opacity(0.75)
                    )
                    .frame(width: geo.size.width * 1.1)
                    .position(
                        x: geo.size.width * 0.78,
                        y: geo.size.height * 0.56
                    )
                    .blur(radius: 115)

                // 🟡 Yellow blob (left middle - blur -10%)
                Circle()
                    .fill(
                        Color(red: 1.0, green: 0.82, blue: 0.35)
                            .opacity(0.85)
                    )
                    .frame(width: geo.size.width * 0.8)
                    .position(
                        x: geo.size.width * 0.01,
                        y: geo.size.height * 0.65
                    )
                    .blur(radius: 140)

                // 🔴 Red blob (bottom right - smaller + lowered + blur -10%)
                Circle()
                    .fill(
                        Color(red: 0.96, green: 0.42, blue: 0.48)
                            .opacity(0.75)
                    )
                    .frame(width: geo.size.width * 1)
                    .position(
                        x: geo.size.width * 0.90,
                        y: geo.size.height * 0.99
                    )
                    .blur(radius: 140)

                // Soft gradient overlay
                LinearGradient(
                    colors: [
                        .white.opacity(0.25),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    BlurCustomBackground()
}
