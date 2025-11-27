//
//  CustomButton.swift
//  Mycountdown
//
//  Created by Michael on 11/4/25.
//

import SwiftUI

struct CustomButton: View {
  
  let action: () -> Void
  let text: String
  let frameWidth: CGFloat
  let background: LinearGradient
  let textColor: Color
  let shadowColor: Color
  let borderColor: Color
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        Text(text)
          .font(.system(size: 18, weight: .heavy, design: .default))
      }
      .foregroundStyle(textColor)
      .frame(height: 56)
      .frame(maxWidth: frameWidth)
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(.clear)
            .blur(radius: 14)
          
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(background)
            .blendMode(.plusLighter)
            .opacity(1)
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .strokeBorder(borderColor, lineWidth: 1)
          .blendMode(.overlay)
      )
      .shadow(color: shadowColor, radius: 1, x: 0, y: 2)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  CustomButton(
    action: { },
    text: "Cancel",
    frameWidth: 150,
    background:  LinearGradient(
      colors: [
        Color.white.opacity(0.25),
        Color.white.opacity(0.05),
        Color.clear,
        Color.white.opacity(0.15)
      ],
      startPoint: .top,
      endPoint: .bottom
    ),
    textColor: .black,
    shadowColor: Color.searchBarGray.opacity(0.5),
    borderColor: .searchBarGray)
  .padding()
}
