//
//  AppStoreRatingSection.swift
//  Mycountdown
//
//  Created by Alexander Gryshanskiy on 14.01.2026.
//

import SwiftUI

struct AppStoreRatingSection: View {
    let rating: Double
    var switchColorMode: Bool = true
    
    @Environment(\.colorScheme) private var  colorScheme
    
    init(rating: Double, switchColorMode: Bool = true) {
        self.rating = rating
        self.switchColorMode = switchColorMode
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(switchColorMode == true ? colorScheme == .dark ? .whiteLaurelLeft : .blackLaurelLeft : .blackLaurelLeft)
                .resizable()
                .scaledToFit()
                .frame(height: 75)
                .opacity(0.8)
            
            VStack(spacing: 6) {
                StarRatingView(rating: rating)
                
                Text("4.8 App Store")
                    .font(.system(size: 20, weight: .semibold).italic())
                    .foregroundStyle(switchColorMode == true ? Color.primary : Color.black)
                    .lineLimit(1)
            }
            .layoutPriority(1)
            .frame(minWidth: 0)
            
            Image(switchColorMode == true ? colorScheme == .dark ? .whiteLaurelRight : .blackLaurelRight : .blackLaurelRight)
                .resizable()
                .scaledToFit()
                .frame(height: 75)
                .opacity(0.8)
        }
    }
}

#Preview {
    AppStoreRatingSection(rating: 4.8)
}
