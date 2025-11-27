//
//  AppIntent.swift
//  MycountdownWidgetsExtension
//
//  Created by Michael on 11/17/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource { "Widget configuration" }
  static var description: IntentDescription { "Choose event to show in widget" }
  
  @Parameter(
    title: "Select event",
    default: nil
  )
  var selected: CountdownEntity?
}


struct CountdownEntity: AppEntity, Identifiable {
  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Countdown event")
  
  static var defaultQuery = CountdownQuery()
  
  let id: UUID
  let name: String
  let date: Date
  let icon: String
  let colorHex: String
  
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)",
      subtitle: "\(date.formatted(date: .abbreviated, time: .shortened))"
    )
  }
}

struct CountdownQuery: EntityQuery {
  func suggestedEntities() async throws -> [CountdownEntity] {
    let items = WidgetStorage.load()
    return items.map { CountdownEntity(id: $0.id, name: $0.name, date: $0.date, icon: $0.icon, colorHex: $0.colorHex) }
  }
  
  func entities(for identifiers: [UUID]) async throws -> [CountdownEntity] {
    let items = WidgetStorage.load()
    return items
      .filter { identifiers.contains($0.id) }
      .map { CountdownEntity(id: $0.id, name: $0.name, date: $0.date, icon: $0.icon, colorHex: $0.colorHex) }
  }
}

enum WidgetStorage {
  static func load() -> [WidgetCountdown] {
    guard let data = UserDefaults(suiteName: "group.com.aliang")?
      .data(forKey: "countdowns") else { return [] }
    
    return (try? JSONDecoder().decode([WidgetCountdown].self, from: data)) ?? []
  }
}
