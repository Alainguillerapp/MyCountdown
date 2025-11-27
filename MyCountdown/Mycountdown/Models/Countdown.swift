//
//  Countdown.swift
//  Mycountdown
//
//  Created by Michael on 11/7/25.
//

import Foundation
import SwiftData

struct WidgetCountdown: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let icon: String
    let colorHex: String
}

@Model
final class Countdown: Identifiable {
  
  var id: UUID
  var name: String?
  var icon: String?
  var date: Date
  var time: Date?
  var colorHex: String?
  var remindWhenFinished: Bool
  var remindDayBefore: Bool
  var remindWeekBefore: Bool
  var organizer: String?
  var tags: [String] = ["🎉 Celebrations", "⏰ Reminders", "🎂 Birthdays"]
  var selectedTags: [String]
  var order: Int?
  var allDay: Bool
  var weekdaysOnly: Bool
  var selectedUnits: [String]
  var note: String?
  var isArchived: Bool = false
  var compactFormat: String?
  @Attribute var userPickedDate: Date?
  @Attribute var userPickedTime: Date?

  init(
    id: UUID = UUID(),
    name: String? = nil,
    icon: String? = nil,
    date: Date,
    time: Date? = nil,
    colorHex: String? = nil,
    remindWhenFinished: Bool = true,
    remindDayBefore: Bool = false,
    remindWeekBefore: Bool = false,
    organizer: String? = nil,
    tags: [String] = [],
    selectedTags: [String] = [],
    order: Int? = nil,
    allDay: Bool = false,
    weekdaysOnly: Bool = false,
    selectedUnits: [String] = ["Years","Months", "Weeks", "Days", "Hours", "Minutes", "Seconds"],
    note: String? = nil,
    isArchived: Bool = false,
    compactactFormat: String  = "Days",
    userPickedDate: Date? = nil,
    userPickedTime: Date? = nil,
  ) {
    self.id = id
    self.name = name
    self.icon = icon
    self.date = date
    self.time = time
    self.colorHex = colorHex
    self.remindWhenFinished = remindWhenFinished
    self.remindDayBefore = remindDayBefore
    self.remindWeekBefore = remindWeekBefore
    self.organizer = organizer
    self.tags = tags
    self.selectedTags = selectedTags
    self.order = order
    self.allDay = allDay
    self.weekdaysOnly = weekdaysOnly
    self.selectedUnits = selectedUnits
    self.note = note
    self.isArchived = isArchived
    self.compactFormat = compactactFormat
    self.userPickedDate = userPickedDate
    self.userPickedTime = userPickedTime
  }
}

extension Countdown {
  var shareText: String {
    let formattedDate = date.formatted(date: .abbreviated, time: .shortened)
    
    return """
        Countdown: \(name ?? "Countdown")
        Date: \(formattedDate)
        
        Open in App:
        mycountdown://countdown?id=\(id.uuidString)
        
        Countdown by MyCountdown
        """
  }
}
