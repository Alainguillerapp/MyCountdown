//
//  PickATimeView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI

struct PickATimeView: View {
  
  @Binding var allDay: Bool
  @Binding var time: Date
  @Binding var selectedDate: Date
  
  private let calendar = Calendar.current
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Pick a time".localized.uppercased())
        .font(.system(size: 15, weight: .semibold, design: .rounded))
      
      VStack {
        Toggle(isOn: $allDay) {
          Text("All-day".localized)
            .font(.system(size: 18, weight: .bold, design: .rounded))
        }
        .tint(.accent)
        .padding()
        .onChange(of: allDay) { _, newValue in
          if newValue {
            let startOfSelectedDay = calendar.startOfDay(for: selectedDate)
            if let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfSelectedDay) {
              time = startOfNextDay
            } else {
              time = calendar.startOfDay(for: Date()).addingTimeInterval(24*60*60)
            }
          } else {
            let hour = calendar.component(.hour, from: time)
            if hour == 0 && calendar.component(.minute, from: time) == 0 {
              if let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: selectedDate) {
                time = noon
              }
            }
          }
        }
        
        if !allDay {
          DatePicker(
            "Select Time",
            selection: $time,
            displayedComponents: [.hourAndMinute]
          )
          .datePickerStyle(.wheel)
          .labelsHidden()
          .frame(maxWidth: .infinity)
          .padding(.horizontal)
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.primaryBackgroundTheme)
          .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
      )
    }
    .padding(.horizontal)
    .animation(.smooth, value: allDay)
  }
}

#Preview {
  PickATimeView(allDay: .constant(false), time: .constant(.now), selectedDate: .constant(Date()))
}
