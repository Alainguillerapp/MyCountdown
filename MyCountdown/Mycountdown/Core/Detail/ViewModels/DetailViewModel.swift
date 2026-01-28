//
//  DetailViewModel.swift
//  Mycountdown
//
//  Created by Michael on 11/11/25.
//

import Foundation
import Combine
import SwiftData
import WidgetKit

final class DetailViewModel: ObservableObject {
  
  @Published var countdown: Countdown
  
  var formattedDate: String {
    let date = countdown.date
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM yyyy"
    return formatter.string(from: date)
  }
  var formattedTime: String {
    guard let time = countdown.time else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: time)
  }
  
  init(countdown: Countdown) {
    self.countdown = countdown
  }
  
  func deleteCountdown(context: ModelContext) {
    context.delete(countdown)
    NotificationManager.shared.cancel(for: countdown)
    do {
      try context.save()
    } catch {
      print("❌ Failed to delete countdown:", error.localizedDescription)
    }
  }
  
  func duplicateCountdown(context: ModelContext, completion: @escaping () -> Void) {
    let newCountdown = Countdown(
      id: UUID(),
      name: countdown.name,
      icon: countdown.icon,
      date: countdown.date,
      time: countdown.time,
      colorHex: countdown.colorHex,
      remindWhenFinished: countdown.remindWhenFinished,
      remindDayBefore: countdown.remindDayBefore,
      remindWeekBefore: countdown.remindWeekBefore,
      organizer: countdown.organizer,
      tags: countdown.tags,
      selectedTags: countdown.selectedTags,
      order: countdown.order,
      allDay: countdown.allDay,
      weekdaysOnly: countdown.weekdaysOnly,
      selectedUnits: countdown.selectedUnits,
      note: countdown.note,
      userPickedDate: countdown.userPickedDate,
      userPickedTime: countdown.userPickedTime
    )
    
    context.insert(newCountdown)
    saveChanges(context: context)
    completion()
    NotificationManager.shared.schedule(for: newCountdown)
    saveCountdownsToWidget(context: context)
  }
  
  //MARK: SAVE TO THE WIDGET
  private func saveCountdownsToWidget(context: ModelContext) {
    let allCountdowns = fetchAllCountdowns(context: context)
    
    // Map SwiftData Countdown -> WidgetCountdown
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
  
  func fetchAllCountdowns(context: ModelContext) -> [Countdown] {
      let descriptor = FetchDescriptor<Countdown>(sortBy: [SortDescriptor(\.date)])
      do {
          return try context.fetch(descriptor)
      } catch {
          print("❌ Failed to fetch countdowns:", error)
          return []
      }
  }
  
  func saveChanges(context: ModelContext) {
    do {
      try context.save()
    } catch {
      print("❌ Failed to save countdown changes:", error)
    }
  }
}
