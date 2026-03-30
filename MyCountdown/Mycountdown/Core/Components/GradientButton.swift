//
//  GradientButton.swift
//  Mycountdown
//
//  Created by Alexander Gryshanskiy on 05.01.2026.
//

import SwiftUI

struct GradientButton: View {

    let title: String
    let subtitle: String?
    let action: () -> Void
    
    private var titleScaleFactor: CGFloat {
        title.count > 31 ? 0.6 : 1.0
    }

    init(
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: subtitle == nil ? 0 : 4) {

                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(titleScaleFactor)
                    .padding(.horizontal, 3)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .bold))
                        .opacity(0.9)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.leading, -6)
                }
                    
            }
            .padding(.vertical, subtitle == nil ? 14 : 12)
        }
        .buttonStyle(GradientGlowButtonStyle())
    }
}
