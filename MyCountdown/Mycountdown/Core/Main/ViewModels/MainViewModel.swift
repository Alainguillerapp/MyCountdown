//
//  MainViewModel.swift
//  Mycountdown
//
//  Created by Michael on 11/10/25.
//

import Foundation
import SwiftUI
import SwiftData
import EventKit
import WidgetKit

@MainActor
final class MainViewModel: ObservableObject {
  
  @Published var manualOrder: [Countdown] = []
  @Published var searchText: String = ""
  @Published var selectedTag: String? = nil
  private let eventStore = EKEventStore()
  
  func filter(_ countdowns: [Countdown]) -> [Countdown] {
    let filtered = countdowns.filter { countdown in
      let matchesSearch = searchText.isEmpty || countdown.name?.localizedCaseInsensitiveContains(searchText) == true
      let matchesTag = selectedTag == nil || countdown.selectedTags.contains(selectedTag!)
      return matchesSearch && matchesTag
    }
    return filtered
  }
  
  func allTags(from countdowns: [Countdown]) -> [String] {
    let tags = countdowns.flatMap { $0.selectedTags }
    return Array(Set(tags)).sorted()
  }
  
  func updateSelectedTagIfNeeded(countdowns: [Countdown]) {
    let currentTags = allTags(from: countdowns)
    
    if let selectedTag, !currentTags.contains(selectedTag) {
      self.selectedTag = nil
      return
    }

    if let selectedTag {
      let hasCountdown = countdowns.contains { $0.selectedTags.contains(selectedTag) }
      if !hasCountdown {
        self.selectedTag = nil
      }
    }
  }
  
  func moveItem(from source: IndexSet, to destination: Int, modelContext: ModelContext) {
    manualOrder.move(fromOffsets: source, toOffset: destination)
    for (index, countdown) in manualOrder.enumerated() {
      countdown.order = index
    }
    try? modelContext.save()
  }
  
  // MARK: - Remove single countdown from widget
  func removeCountdownFromWidget(id: UUID) {
    let defaults = UserDefaults(suiteName: "group.com.aliang")
    guard let data = defaults?.data(forKey: "countdowns"),
          var widgetCountdowns = try? JSONDecoder().decode([WidgetCountdown].self, from: data) else {
      return
    }
    widgetCountdowns.removeAll { $0.id == id }
    
    if let updatedData = try? JSONEncoder().encode(widgetCountdowns) {
      defaults?.set(updatedData, forKey: "countdowns")
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
  
  func requestCalendarWritePermission() async -> Bool {
    return await withCheckedContinuation { continuation in
      eventStore.requestFullAccessToEvents { granted, error in
        continuation.resume(returning: granted)
      }
    }
  }
  
  func openCalendar() {
    // Open Apple Calendar app at today
    if let url = URL(string: "calshow://") {
      UIApplication.shared.open(url)
    }
  }
  
  func exportAllCountdownsToCalendar(_ countdowns: [Countdown]) {
    Task {
      let granted = await requestCalendarWritePermission()
      guard granted else {
        print("No permission to write to calendar")
        return
      }
      
      for countdown in countdowns {
        let event = EKEvent(eventStore: eventStore)
        event.title = countdown.name
        event.startDate = countdown.date
        event.endDate = countdown.date.addingTimeInterval(60 * 60)
        event.notes = "Created from MyCountdown App"
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
          try eventStore.save(event, span: .thisEvent, commit: false)
        } catch {
          print("Error saving event for \(countdown.name ?? ""): \(error)")
        }
      }
      
      // Commit everything at once (значно швидше)
      do {
        try eventStore.commit()
        print("All events exported successfully")
      } catch {
        print("Commit error: \(error)")
      }
    }
  }
}
