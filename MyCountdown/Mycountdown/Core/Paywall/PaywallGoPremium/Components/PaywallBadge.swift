//
//  PaywallBadge.swift
//  Mycountdown
//
//  Created by GetApple on 14.01.2026.
//

import SwiftUI

struct PaywallBadge: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                BadgeShape(cornerRadius: 10)
                    .fill(.proYellow)
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}
