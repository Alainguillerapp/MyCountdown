//
//  CalendarViewModel.swift
//  Mycountdown
//
//  Created by Michael on 11/19/25.
//

import Foundation
import SwiftData
import EventKit
import SwiftUI

final class CalendarImportViewModel: ObservableObject {
  
  private let eventStore = EKEventStore()
  private let modelContext: ModelContext
  
  @Published var importedEvents: [EKEvent] = []
  @Published var selectedEventIDs: Set<String> = []
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  @MainActor
  func loadEvents() async {
    let granted = await withCheckedContinuation { continuation in
      eventStore.requestFullAccessToEvents { granted, _ in
        continuation.resume(returning: granted)
      }
    }
    guard granted else { return }
    
    let calendars = eventStore.calendars(for: .event)
    let startDate = Date()  // від сьогодні
    let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? startDate
    
    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
    let events = eventStore.events(matching: predicate)
      .sorted(by: { $0.startDate < $1.startDate })
    
    var uniqueEventsDict: [String: EKEvent] = [:]
    for event in events {
      let key = "\(event.title ?? "")_\(event.startDate.formatted(.iso8601))"
      if uniqueEventsDict[key] == nil {
        uniqueEventsDict[key] = event
      }
    }
    
    self.importedEvents = Array(uniqueEventsDict.values)
  }
  
  func requestCalendarWritePermission() async -> Bool {
      return await withCheckedContinuation { continuation in
          eventStore.requestWriteOnlyAccessToEvents { granted, error in
              continuation.resume(returning: granted)
          }
      }
  }
  
  func toggleSelection(_ event: EKEvent) {
    if selectedEventIDs.contains(event.eventIdentifier) {
      selectedEventIDs.remove(event.eventIdentifier)
    } else {
      selectedEventIDs.insert(event.eventIdentifier)
    }
  }
  
  func importSelectedEvents() {
    let colors: [Color] = [
      .expansesRed,
      .expansesBlue,
      .expansesGreen,
      .expansesOrange,
      .expansesPurple
    ]    
    
    for event in importedEvents where selectedEventIDs.contains(event.eventIdentifier) {
      let countdown = Countdown(
        id: UUID(),
        name: event.title ?? "No title",
        icon: "📅",
        date: event.startDate,
        colorHex: colors.randomElement()?.toHexString(),
        order: nil,
        isArchived: false
      )
      modelContext.insert(countdown)
    }
    try? modelContext.save()
  }
}
