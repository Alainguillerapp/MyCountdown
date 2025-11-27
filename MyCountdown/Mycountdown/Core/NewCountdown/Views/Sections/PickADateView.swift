//
//  PickADateView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI

struct PickADateView: View {
  
  @Binding var selectedDate: Date
  @Binding var weekdaysOnly: Bool
  @Binding var allDay: Bool
  @Binding var time: Date
  
  private let calendar = Calendar.current
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Pick a date".localized.uppercased())
        .font(.system(size: 15, weight: .semibold, design: .rounded))
      
      VStack {
        DatePicker(
          "Select Date",
          selection: $selectedDate,
          in: Date()...,
          displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .padding(.horizontal)
        
        Toggle(isOn: $weekdaysOnly) {
          Text("Count only weekdays".localized)
            .font(.system(size: 18, weight: .bold, design: .rounded))
          Text("(Monday to Friday)".localized)
            .font(.system(size: 18, weight: .regular, design: .rounded))
        }
        .tint(.accent)
        .padding(.horizontal)
        .padding(.bottom)
      }
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
  PickADateView(selectedDate: .constant(Date()), weekdaysOnly: .constant(true), allDay: .constant(true), time: .constant(Date()))
}
