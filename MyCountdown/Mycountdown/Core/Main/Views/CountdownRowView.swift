//
//  CountdownRowView.swift
//  Mycountdown
//
//  Created by Michael on 11/7/25.
//

import SwiftUI

struct CountdownRowView: View {
  
  @State private var showDeleteAlert = false
  
  let countdown: Countdown
  private var calendar: Calendar { Calendar.current }
  @State private var now: Date = .now
  private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(countdown: Countdown) {
        self.countdown = countdown
    }

  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      // MARK: - Icon plus Name
      if let icon = countdown.icon {
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(hex: countdown.colorHex ?? "#FBC024")?.opacity(0.2)
                ?? .expansesOrange.opacity(0.2))
          .frame(width: 72, height: 72)
          .overlay {
            Text(icon)
              .font(.system(size: 34))
          }
        Text(countdown.name ?? "NONAME")
          .font(.system(size: 20, weight: .semibold, design: .rounded))
          .lineLimit(2)
          .foregroundColor(.primary)
          .padding(.leading)
        
        Spacer()
        
        if let firstTag = countdown.selectedTags.first, let firstChar = firstTag.first {
          Text(String(firstChar))
            .font(.system(size: 18, weight: .semibold))
            .padding(6)
            .background(
              RoundedRectangle(cornerRadius: 30)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .padding(.trailing)
        }
      }
      
      if countdown.date < Date() {
        RoundedRectangle(cornerRadius: 20)
          .fill(.white)
          .frame(width: 72, height: 72)
          .overlay {
            VStack(spacing: 0) {
              Image(.checkmarkIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundColor(Color(hex: countdown.colorHex ?? "#FBC024") ?? .expansesOrange)
            }
          }
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .stroke(Color(hex: countdown.colorHex ?? "#FBC024") ?? .expansesOrange, lineWidth: 2)
          )
      } else {
        daysLeftSection
      }
    }
    .padding()
    .background(
      rowBackground
    )
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color.borderRow, lineWidth: 1)
    )
    .padding(.top, 6)
    .onReceive(timer) { currentTime in
        self.now = currentTime
    }
  }
}

#Preview {
  CountdownRowView(
    countdown: .init(
      id: UUID(),
      name: "Birthday Party",
      icon: "🎂",
      date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
      time: Date(),
      colorHex: "#FBC024",
      remindWhenFinished: true,
      remindDayBefore: false,
      remindWeekBefore: false,
      organizer: "Misha",
      tags: ["🎂 Birthdays", "🎉 Celebrations"]
    )
  )
}

extension CountdownRowView {
  private var compactDisplay: (value: Int, unit: String) {
    let target = Calendar.current.date(byAdding: .day, value: 0, to: countdown.date) ?? countdown.date
    let seconds = Int(target.timeIntervalSince(now))
    
    let minutes = Int(ceil(Double(seconds) / 60))
    let hours = Int(ceil(Double(seconds) / 3600))
    let days = Int(ceil(Double(seconds) / 86400))
    
    switch countdown.compactFormat {
    case "Weeks".localized:
      let weeks =  days / 7
      return (weeks, "WEEKS".localized)
      
    case "Months".localized:
      let months = days / 30
      return (months, "MONTHS".localized)
      
    case "Years".localized:
      let years = days / 365
      return (years, "YEARS".localized)
      
    default:
      if seconds >= 86400 {
        return (days, "DAYS".localized)
      }
      
      if seconds >= 3600 {
          return (hours, "HOURS".localized)
      }
      
      if seconds >= 60 {
        return (minutes, "MINUTES".localized)
      }
    }
    return (seconds, "SECONDS".localized)
  }
  
  private var daysLeftSection: some View {
    let display = compactDisplay
    
    return RoundedRectangle(cornerRadius: 20)
      .fill(.white)
      .frame(width: 72, height: 72)
      .overlay {
        VStack(spacing: 0) {
          Text("\(display.value)")
            .font(.system(size: 26, weight: .semibold))
            .minimumScaleFactor(0.4)
            .foregroundStyle(Color(hex: countdown.colorHex ?? "#FBC024") ?? .expansesOrange)
          Text(display.unit)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.gray)
        }
      }
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(Color(hex: countdown.colorHex ?? "#FBC024") ?? .expansesOrange, lineWidth: 2)
      )
  }
  
  private var rowBackground: some View {
    ZStack(alignment: .top) {
      RoundedRectangle(cornerRadius: 20)
        .fill(Color(hex: countdown.colorHex ?? "#FBC024")?.opacity(0.1)
              ?? .expansesOrange.opacity(0.1))
      
      RoundedRectangle(cornerRadius: 20)
        .fill(Color(hex: countdown.colorHex ?? "#FBC024") ?? .expansesOrange)
        .frame(height: 6)
        .clipShape(RoundedCorners(topLeft: 25, topRight: 25))
    }
  }
}
