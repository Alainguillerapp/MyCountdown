//
//  PopoverButton.swift
//  Mycountdown
//
//  Created by Michael on 11/11/25.
//

import SwiftUI

struct PopoverButton: View {
  
  let title: String
  let systemImage: String
  let tint: Color
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: systemImage)
          .frame(width: 24, height: 24)
          .foregroundStyle(tint)
        Text(title)
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.searchBarGray)
      }
      .padding(.horizontal, 14)
    }
  }
}
