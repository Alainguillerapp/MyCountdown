//
//  GradientGlowButtonStyle.swift
//  Mycountdown
//
//  Created by Alexander Gryshanskiy on 05.01.2026.
//

import SwiftUI

struct GradientGlowButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(
                            LinearGradient(colors: [
                                Color(red: 0.45, green: 0.48, blue: 0.95),
                                Color(red: 0.52, green: 0.39, blue: 0.78)
                            ], startPoint: .leading, endPoint: .trailing
                                          )
                        )
                    
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.white.opacity(0.25))
                        .blur(radius: 20)
                        .opacity(configuration.isPressed ? 0.3 : 0.6)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
