//
//  MycountdownApp.swift
//  Mycountdown
//
//  Created by Danil Ovcharenko on 30.10.2025.
//

import SwiftUI
import SwiftData

@main
struct MycountdownApp: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject var store = StoreManager()
  
  var body: some Scene {
    WindowGroup {
      OrientationLockedView {
        MainView()
          .modelContainer(for: Countdown.self)
          .environmentObject(store)
          .onOpenURL { url in
            handleDeepLink(url)
          }
      }
    }
  }
  
  func handleDeepLink(_ url: URL) {
    guard url.scheme == "myapp",
          url.host == "countdown",
          let idString = url.pathComponents.dropFirst().first,
          let id = UUID(uuidString: idString) else { return }
    
    NotificationCenter.default.post(
      name: .openCountdownDetails,
      object: nil,
      userInfo: ["id": id]
    )
  }
}

extension Notification.Name {
  static let openCountdownDetails = Notification.Name("openCountdownDetails")
}
