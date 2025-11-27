//
//  NotificationManager.swift
//  Mycountdown
//
//  Created by Michael on 11/13/25.
//

import Foundation
import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
  
  static let shared = NotificationManager()
  private override init() {
    super.init()
    UNUserNotificationCenter.current().delegate = self
  }
  
  // MARK: - Request Authorization
  func requestAuthorization() {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
      if let error = error {
        print("❌ Notification permission error:", error.localizedDescription)
        return
      }
      print(granted ? "✅ Granted" : "❌ Denied")
    }
  }
  
  // MARK: - Schedule based on toggles
  func schedule(for countdown: Countdown) {
    
    let date = countdown.date
    let name = countdown.name ?? "Countdown"
    
    var notifications: [(id: String, date: Date, body: String)] = []
    
    // When countdown finishes
    if countdown.remindWhenFinished {
        notifications.append((id: "\(countdown.id)_main", date: date, body: "Your countdown is completed!".localized))
    }
    // 1 day before
    if countdown.remindDayBefore,
       let before = Calendar.current.date(byAdding: .day, value: -1, to: date) {
      let body = countdown.allDay ?
        "Your countdown is tomorrow!".localized :
        "Your countdown is tomorrow at \(formattedTime(date))!".localized
      notifications.append((id: "\(countdown.id)_1day", date: before, body: body))
    }
    
    // 1 week before
    if countdown.remindWeekBefore,
       let before = Calendar.current.date(byAdding: .day, value: -7, to: date) {
      let body = countdown.allDay ?
        "One week left until your countdown!".localized :
        "One week left until your countdown at \(formattedTime(date))!".localized
      notifications.append((id: "\(countdown.id)_7days", date: before, body: body))
    }
    
    // Schedule all notifications with badge count
    for (index, notif) in notifications.enumerated() {
      let badgeNumber = notifications.count - index
      schedule(id: notif.id, title: name, body: notif.body, date: notif.date, allDay: countdown.allDay, badge: badgeNumber)
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.checkScheduledNotifications(for: countdown)
    }
  }
  
  // MARK: - Single Schedule Helper
  private func schedule(
    id: String,
    title: String,
    body: String,
    date: Date,
    allDay: Bool,
    badge: Int
  ) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    content.badge = NSNumber(value: badge)
    
    var comps = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: date
    )
    
    if allDay {
      comps.hour = 0
      comps.minute = 0
    }
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("❌ Schedule error:", error.localizedDescription)
      } else {
        print("📅 Scheduled notification: \(id) at \(comps)")
      }
    }
  }
  
  // MARK: - Foreground Notifications
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }
  
  // MARK: - Cancel
  func cancel(for countdown: Countdown) {
    let ids = [
      "\(countdown.id)_main",
      "\(countdown.id)_1day",
      "\(countdown.id)_7days"
    ]
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
    print("🗑 Canceled notifications for countdown: \(countdown.id)")
  }
  
  // MARK: - Verify
  private func checkScheduledNotifications(for countdown: Countdown) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
      let ids = [
        "\(countdown.id)_main",
        "\(countdown.id)_1day",
        "\(countdown.id)_7days"
      ]
      for id in ids {
        if requests.contains(where: { $0.identifier == id }) {
          print("✅ Confirmed scheduled: \(id)")
        } else {
          print("⚠️ Not scheduled: \(id)")
        }
      }
    }
  }
  
  private func formattedTime(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f.string(from: date)
  }
}
