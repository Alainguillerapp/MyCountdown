//
//  RemindMeView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI

struct RemindMeView: View {
  
  @Binding var countdownFinishesRemind: Bool
  @Binding var dayBeforeRemind: Bool
  @Binding var weekBeforeRemind: Bool

  var body: some View {
    
    VStack(alignment: .leading, spacing: 16) {
      Text("Remind me".localized.uppercased())
        .font(.system(size: 15, weight: .semibold, design: .rounded))
      
      VStack(spacing: 20) {
        Toggle(isOn: $countdownFinishesRemind) {
          Text("When the countdown finishes".localized)
            .font(.system(size: 18, weight: .bold, design: .rounded))
        }
        
        Toggle(isOn: $dayBeforeRemind) {
          Text("1 day before".localized)
            .font(.system(size: 18, weight: .bold, design: .rounded))
        }
        
        Toggle(isOn: $weekBeforeRemind) {
          Text("1 week before".localized)
            .font(.system(size: 18, weight: .bold, design: .rounded))
        }
      }
      .tint(.accent)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.primaryBackgroundTheme)
          .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
      )
    }
    .padding(.horizontal)
  }
}

#Preview {
  RemindMeView(
    countdownFinishesRemind: .constant(true),
    dayBeforeRemind: .constant(false),
    weekBeforeRemind: .constant(false)
  )
}
