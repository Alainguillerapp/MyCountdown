//
//  NewCountdownViewModel.swift
//  Mycountdown
//
//  Created by Michael on 11/7/25.
//

import Foundation
import SwiftData
import SwiftUI
import WidgetKit

final class NewCountdownViewModel: ObservableObject {
  // MARK: - Mode
  enum Mode {
    case creating
    case editing(Countdown)
  }
  
  let mode: Mode
  @Published var name: String = ""
  @Published var emoji: String = "📅"
  
  // MARK: - Date & Time
  @Published var date: Date = Date()
  @Published var time: Date = Date()
  @Published var allDay: Bool = true
  @Published var weekdaysOnly: Bool = false
  
  // MARK: - Color
  @Published var color: Color = .clear
  @Published var userSelectedColor = false
  private let presetColors: [Color] = [
    .expansesRed,
    .expansesBlue,
    .expansesGreen,
    .expansesOrange,
    .expansesPurple
  ]
  
  // MARK: - Reminders
  @Published var remindWhenFinished: Bool = true
  @Published var remindDayBefore: Bool = false
  @Published var remindWeekBefore: Bool = false
  
  // MARK: - Tags
  @Published var tags: [String] = []
  @Published var selectedTags: [String] = []
  
  // MARK: - Countdown format
  @Published var selectedUnits: [String] = ["Hours".localized, "Minutes".localized, "Seconds".localized]
  @Published var sameFormatWidget: Bool = false
  @Published var compactFormat: String = "Days".localized
  
  // MARK: - Errors
  @Published var showNameError = false
  
  // MARK: - Init
  init(mode: Mode) {
    self.mode = mode
    
    if case let .editing(countdown) = mode {
      self.name = countdown.name ?? ""
      self.emoji = countdown.icon ?? "📅"
      self.date = countdown.date
      self.time = countdown.time ?? countdown.date
      self.weekdaysOnly = countdown.weekdaysOnly
      self.allDay = countdown.allDay
      self.color = Color(hex: countdown.colorHex ?? "#FBC024") ?? .expansesOrange
      self.userSelectedColor = true
      self.remindWhenFinished = countdown.remindWhenFinished
      self.remindDayBefore = countdown.remindDayBefore
      self.remindWeekBefore = countdown.remindWeekBefore
      self.tags = countdown.tags
      self.selectedTags = countdown.selectedTags
      self.selectedUnits = countdown.selectedUnits
      self.sameFormatWidget = true
      self.compactFormat = countdown.compactFormat ?? "Days".localized
      self.date = countdown.userPickedDate ?? countdown.date
      self.time = countdown.userPickedTime ?? countdown.time ?? countdown.date
    }
  }
  
  // MARK: - Decision: Create OR Update
  func save(context: ModelContext) {
    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
      showNameError = true
      return
    }
    
    switch mode {
    case .creating:
      createCountdown(context: context)
    case .editing(let existing):
      updateCountdown(existing, context: context)
    }
  }
  
  // MARK: - Create
  private func createCountdown(context: ModelContext) {
    let finalDate = buildFinalDate()
    
    let assignedColor: Color
    
    if !userSelectedColor {
      assignedColor = assignColorForNewCountdown(context: context)
    } else {
      assignedColor = color
    }
      
    let finalTags = tags.isEmpty ? [] : tags
    
    let newCountdown = Countdown(
      name: name,
      icon: emoji,
      date: finalDate,
      time: time,
      colorHex: assignedColor.toHexString(),
      remindWhenFinished: remindWhenFinished,
      remindDayBefore: remindDayBefore,
      remindWeekBefore: remindWeekBefore,
      organizer: nil,
      tags: finalTags,
      selectedTags: selectedTags,
      allDay: allDay,
      weekdaysOnly: weekdaysOnly,
      selectedUnits: selectedUnits,
      compactactFormat: compactFormat,
      userPickedDate: date,
      userPickedTime: time
    )
    
    context.insert(newCountdown)
    NotificationManager.shared.schedule(for: newCountdown)
    saveCountdownsToWidget(context: context)
  }
  
  
  // MARK: - Update
  private func updateCountdown(_ countdown: Countdown, context: ModelContext) {
    let finalDate = buildFinalDate()
    
    let assignedColor = userSelectedColor ? color : assignColorForNewCountdown(context: context)
      
    countdown.colorHex = assignedColor.toHexString()
    countdown.name = name
    countdown.icon = emoji
    countdown.date = finalDate
    countdown.time = time
    countdown.allDay = allDay
    countdown.tags = tags
    countdown.selectedTags = selectedTags
    countdown.selectedUnits = selectedUnits
    countdown.remindWhenFinished = remindWhenFinished
    countdown.remindDayBefore = remindDayBefore
    countdown.remindWeekBefore = remindWeekBefore
    countdown.compactFormat = compactFormat
    countdown.weekdaysOnly = weekdaysOnly
    countdown.userPickedDate = date
    countdown.userPickedTime = time
    
    do {
      try context.save()
      NotificationManager.shared.schedule(for: countdown)
      saveCountdownsToWidget(context: context)
    } catch {
      print("❌ Failed to save countdown:", error)
    }
  }
  
  //MARK: SAVE TO THE WIDGET
  private func saveCountdownsToWidget(context: ModelContext) {
    let allCountdowns = fetchAllCountdowns(context: context)
    
    let widgetCountdowns = allCountdowns.map { countdown in
      WidgetCountdown (
        id: countdown.id,
        name: countdown.name ?? "",
        date: countdown.date,
        icon: countdown.icon ?? "",
        colorHex: countdown.colorHex ?? ""
      )
    }
    
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(widgetCountdowns) {
      UserDefaults(suiteName: "group.com.aliang")?.set(data, forKey: "countdowns")
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
  
  private func isUserSelectedColor() -> Bool {
    return presetColors.contains(where: { $0.toHexString() == color.toHexString() })
  }
  
  func assignColorForNewCountdown(context: ModelContext) -> Color {
    let allCountdowns = fetchAllCountdowns(context: context)
    let nextIndex = allCountdowns.count % presetColors.count
    
    return presetColors[nextIndex]
  }
  
  private func fetchAllCountdowns(context: ModelContext) -> [Countdown] {
    let descriptor = FetchDescriptor<Countdown>(sortBy: [SortDescriptor(\.date)])
    do {
      return try context.fetch(descriptor)
    } catch {
      print("❌ Failed to fetch countdowns:", error)
      return []
    }
  }
  
  
  // MARK: - Date helpers in NewCountdownViewModel
  private var calendar: Calendar {
    Calendar.current
  }
  
  func buildFinalDate() -> Date {
    let calendar = Calendar.current
    
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
    
    let baseDate: Date = {
      if allDay {
        return calendar.date(from: components) ?? date
      } else {
        return calendar.date(from: DateComponents(
          year: components.year,
          month: components.month,
          day: components.day,
          hour: timeComponents.hour,
          minute: timeComponents.minute
        )) ?? date
      }
    }()
    
    guard weekdaysOnly else {
      return baseDate
    }
    
    let now = Date()
    if now >= baseDate {
      return baseDate
    }
    
    var current = now
    var result = now
    
    while current < baseDate {
      let start = calendar.startOfDay(for: current)
      let end = calendar.date(byAdding: .day, value: 1, to: start)!
      let weekday = calendar.component(.weekday, from: start)
      
      if weekday != 1 && weekday != 7 {
        let chunkEnd = min(end, baseDate)
        result = result.addingTimeInterval(chunkEnd.timeIntervalSince(current))
      }
      current = end
    }
    
    return result
  }
  
  func buildPreviewFinalDate() -> Date {
    let realFinal = buildFinalDate()
    let now = Date()
    
    guard realFinal > now else { return realFinal }
    
    let diff = realFinal.timeIntervalSince(now)
    let fullDays = Int(diff / 86400)
    let hasRemainder = diff.truncatingRemainder(dividingBy: 86400) > 0
    let previewDays = fullDays + (hasRemainder ? 1 : 0)
    
    return Calendar.current.date(byAdding: .day, value: previewDays, to: now) ?? realFinal
  }
  
  
  func buildPreviewDate() -> Date {
    return buildFinalDate()
  }
  
  var previewDateBinding: Binding<Date> {
    Binding(
      get: { self.buildPreviewDate() },
      set: { newValue in
        self.date = Calendar.current.startOfDay(for: newValue)
        self.time = newValue
        let hour = Calendar.current.component(.hour, from: newValue)
        self.allDay = (hour == 0)
      }
    )
  }
  
  func previewColor(modelContext: ModelContext) -> Color {
    if userSelectedColor {
      return color
    } else {
      return assignColorForNewCountdown(context: modelContext)
    }
  }
}
