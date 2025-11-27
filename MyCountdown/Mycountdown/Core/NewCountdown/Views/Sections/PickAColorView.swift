//
//  PickAColorView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI

struct PickAColorView: View {
  
  @Binding var selectedColor: Color
  @Binding var userSelectedColor: Bool
  
  var onUserPickColor: ((Color) -> ())?
  private let presetColors: [Color] = [
    .expansesOrange, .expansesRed, .expansesBlue, .expansesGreen, .expansesPurple
  ]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Pick a color".localized.uppercased())
        .font(.system(size: 15, weight: .semibold, design: .rounded))
      
      HStack {
        ForEach(presetColors, id: \.self) { color in
          Circle()
            .fill(color)
            .frame(width: 42, height: 42)
            .overlay {
              if selectedColor.toHexString() == color.toHexString() {
                Image("CheckmarkIcon")
                  .resizable()
                  .frame(width: 20, height: 17)
              }
            }
            .onTapGesture {
              withAnimation(.smooth) {
                selectedColor = color
                userSelectedColor = true
              }
            }
        }
        .frame(maxWidth: .infinity)
        
        ZStack {
          ColorPicker("", selection: $selectedColor, supportsOpacity: false)
            .labelsHidden()
            .scaleEffect(1.5)
            .padding(.horizontal)
            .overlay {
              if isCustomColor() {
                Image("CheckmarkIcon")
                  .resizable()
                  .frame(width: 17, height: 14)
              } else {
                Image("colorPickerIcon")
                  .resizable()
                  .frame(width: 20, height: 20)
              }
            }
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.primaryBackgroundTheme)
          .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
      )
    }
    .padding(.horizontal)
  }
  
  private func isCustomColor() -> Bool {
    !presetColors.contains(where: { $0.toHexString() == selectedColor.toHexString() })
  }
}

#Preview {
  PickAColorView(selectedColor: .constant(.expansesOrange), userSelectedColor: .constant(false))
}
