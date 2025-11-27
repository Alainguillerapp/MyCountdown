//
//  TagManager.swift
//  Mycountdown
//
//  Created by Michael on 11/18/25.
//

import Foundation
import SwiftUI
import SwiftData

struct Tag: Identifiable, Codable, Hashable {
  var id: UUID = UUID()
  var emoji: String
  var name: String
  
  var displayName: String { "\(emoji) \(name)" }
}

@MainActor
final class TagManager: ObservableObject {
  
  static let shared = TagManager()
  
  private init() {
    loadDeletedDefaultIDS()
    load()
  }
  
  // MARK: - Default tags
  private let defaultTagsBase: [Tag] = [
    Tag(emoji: "🎂", name: "Birthdays".localized),
    Tag(emoji: "🎉", name: "Celebrations".localized),
    Tag(emoji: "⏰", name: "Reminders".localized)
  ]
  
  // These will be filtered by deletedDefaultTagIDs
  private var defaultTags: [Tag] {
    defaultTagsBase.filter { !deletedDefaultTagIDs.contains($0.id) }
  }
  
  // MARK: - Storage
  @AppStorage("storedTags") private var storedTagsData: Data = Data()
  @Published private(set) var userTags: [Tag] = []
  @Published private(set) var allTags: [Tag] = []
  
  // MARK: - Deleted default IDs
  @AppStorage("deletedDefaultTags") private var deletedDefaultTagsData: Data = Data()
  private var deletedDefaultTagIDs: Set<UUID> = []
  
  // MARK: - Load
  private func load() {
    userTags = decode(storedTagsData)
    updateAllTags()
  }
  
  private func loadDeletedDefaultIDS() {
    deletedDefaultTagIDs = (try? JSONDecoder().decode(Set<UUID>.self, from: deletedDefaultTagsData)) ?? []
  }
  
  private func updateAllTags() {
    allTags = Array(Set(defaultTags + userTags)).sorted { $0.name < $1.name }
  }
  
  // MARK: - Add tag
  func addTag(emoji: String, name: String) {
    let trimmed = name.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return }
    
    guard trimmed.count <= 15 else { return }
    
    let newTag = Tag(emoji: emoji, name: trimmed)
    guard !allTags.contains(newTag) else { return }
    
    userTags.append(newTag)
    save()
  }
  
  // MARK: - Delete tag (default or custom)
  func deleteTag(_ tag: Tag, countdowns: [Countdown]) {
    
    // Remove from custom tags
    userTags.removeAll { $0.id == tag.id }
    
    // Remove default tag (persist deletion)
    if defaultTagsBase.contains(where: { $0.id == tag.id }) {
      deletedDefaultTagIDs.insert(tag.id)
      saveDeletedDefaultIDS()
    }
    
    // Remove the tag from all countdowns
    for countdown in countdowns {
      countdown.selectedTags.removeAll { $0 == tag.displayName }
    }
    save()
  }
  
  // MARK: - Save
  private func save() {
    storedTagsData = encode(userTags)
    updateAllTags()
  }
  
  private func saveDeletedDefaultIDS() {
    deletedDefaultTagsData =
    (try? JSONEncoder().encode(Array(deletedDefaultTagIDs))) ?? Data()
    updateAllTags()
  }
  
  // MARK: - Encoding helpers
  private func encode(_ tags: [Tag]) -> Data {
    return (try? JSONEncoder().encode(tags)) ?? Data()
  }
  
  private func decode(_ data: Data) -> [Tag] {
    return (try? JSONDecoder().decode([Tag].self, from: data)) ?? []
  }
}
