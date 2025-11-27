//
//  MycountdownWidgetsExtension.swift
//  MycountdownWidgetsExtension
//
//  Created by Michael on 11/17/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
  
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), countdowns: WidgetStorage.load())
  }
  
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    let countdowns = selectCountdowns(using: configuration)
    return SimpleEntry(date: Date(), countdowns: countdowns)
  }
  
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    
    let countdowns = selectCountdowns(using: configuration)
    let entry = SimpleEntry(date: Date(), countdowns: countdowns)
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
    
    return Timeline(entries: [entry], policy: .after(nextUpdate))
  }
  
  // MARK: - Selection logic
  private func selectCountdowns(using config: ConfigurationAppIntent) -> [WidgetCountdown] {
    
    let items = WidgetStorage.load()
    
    guard !items.isEmpty else { return [] }
    
    if let selected = config.selected,
       let match = items.first(where: { $0.id == selected.id }) {
      
      var sorted = items.sorted(by: { $0.date < $1.date })
      sorted.removeAll(where: { $0.id == selected.id })
      return [match] + sorted
    }
    
    return items.sorted { $0.date < $1.date }
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let countdowns: [WidgetCountdown]
}

struct MycountdownWidgetsExtensionEntryView: View {
  var entry: Provider.Entry
  @Environment(\.widgetFamily) var family
  
  var isPremiumUser: Bool {
    let defaults = UserDefaults(suiteName: "group.com.aliang")
    return defaults?.bool(forKey: "isPremium") ?? false
  }
  
  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    case .systemLarge:
      largeView
    default:
      smallView
    }
  }
  
  @ViewBuilder
  private var smallView: some View {
    if isPremiumUser {
      if let countdown = entry.countdowns.first {
      let compact = compactDaysLeft(to: countdown.date)
        
        RoundedRectangle(cornerRadius: 25)
          .frame(width: 175, height: 175)
          .foregroundStyle(
            LinearGradient(
              colors: [Color(hex: countdown.colorHex).opacity(0.5), .gray.opacity(0.7)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .blur(radius: 1)
          .overlay {
            VStack(spacing: 0) {
              HStack {
                Text(countdown.icon)
                  .font(.caption)
                  .padding(7)
                  .background(Color(hex: countdown.colorHex))
                  .clipShape(.rect(cornerRadius: 10))
                  .shadow(color: .white, radius: 0.1, x: 0, y: 0)
                
                Text(countdown.name)
                  .font(.system(size: 12, weight: .semibold))
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal)
              
              if isExpired(countdown.date) {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                  .font(.system(size: 50))
                  .foregroundColor(.primary)
                Spacer()

              } else {
                Text("\(compact.value)")
                  .font(.system(size: 50, weight: .semibold))
                Text("\(compact.unit)")
                  .font(.system(size: 18, weight: .light))
                  .padding(.top, -5)
                Spacer()
              }
              
              Text(formattedDate(date: countdown.date))
                .font(.system(size: 10, weight: .light))
            }
            .foregroundStyle(.primary)
            .padding(.vertical)
          }
          .widgetURL(URL(string: "myapp://countdown/\(countdown.id.uuidString)"))
      } else {
        VStack(spacing: 0) {
          Image(.oopsEmpty)
            .resizable()
            .scaledToFit()
            .frame(width: 70, height: 70)
          
          Group {
            Text("You don't have any counters, click the ".localized)
              .font(.system(size: 14, weight: .regular, design: .rounded))
              .foregroundColor(.primary)
            +
            Text("add button.".localized)
              .font(.system(size: 14, weight: .bold, design: .rounded))
              .foregroundColor(.primary)
          }
          .multilineTextAlignment(.center)
          .padding(.horizontal)
          .padding(.top, -10)
        }
      }
    } else {
      VStack {
        Text("⭐️")
          .font(.system(size: 40, weight: .bold, design: .rounded))
        Text("Go premium".localized)
          .font(.system(size: 20, weight: .bold, design: .rounded))
          .foregroundColor(.primary)
      }
    }
  }
  
  @ViewBuilder
  private var mediumView: some View {
    if isPremiumUser {
      if entry.countdowns.isEmpty {
        VStack(spacing: 0) {
          Image(.oopsEmpty)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
          
          Group {
            Text("You don't have any counters, click the ".localized)
              .font(.system(size: 18, weight: .regular, design: .rounded))
              .foregroundColor(.primary)
            +
            Text("add button.".localized)
              .font(.system(size: 18, weight: .bold, design: .rounded))
              .foregroundColor(.primary)
          }
          .multilineTextAlignment(.center)
          .padding(.horizontal)
          .padding(.top, -20)
        }
      } else {
        RoundedRectangle(cornerRadius: 25)
          .frame(width: 380, height: 180)
          .foregroundStyle(
            LinearGradient(
              colors: [
                Color.clear,
                Color.black.opacity(0.15),
                Color.black.opacity(0.1)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .blur(radius: 1)
          .overlay {
            VStack(spacing: 6) {
              let items = entry.countdowns.prefix(3)

              ForEach(items.indices, id: \.self) { index in
                let countdown = items[index]
                let compact = compactDaysLeft(to: countdown.date)

                mediumWidgetRow(
                  icon: countdown.icon,
                  name: countdown.name,
                  date: formattedDate(date: countdown.date),
                  dateToEnd: "\(compact.value)",
                  compactFormat: "\(compact.unit)",
                  color: Color(hex: countdown.colorHex)
                )
                
                if index < items.count - 1 {
                  Divider()
                    .padding(.horizontal, 12)
                }
              }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)
          }
      }
    } else {
      VStack {
        Text("⭐️")
          .font(.system(size: 40, weight: .bold, design: .rounded))
        Text("Go premium".localized)
          .font(.system(size: 20, weight: .bold, design: .rounded))
          .foregroundColor(.primary)
      }

    }
  }
  
  @ViewBuilder
  private var largeView: some View {
    if isPremiumUser {
      if entry.countdowns.isEmpty {
        VStack(spacing: 0) {
          Image(.oopsEmpty)
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
          
          Group {
            Text("You don't have any counters, click the ".localized)
              .font(.system(size: 22, weight: .regular, design: .rounded))
              .foregroundColor(.primary)
            +
              Text("add button.".localized)
              .font(.system(size: 22, weight: .bold, design: .rounded))
              .foregroundColor(.primary)
          }
          .multilineTextAlignment(.center)
          .padding(.horizontal)
          .padding(.top, -10)
        }
      } else {
        RoundedRectangle(cornerRadius: 25)
          .frame(width: 380, height: 400)
          .foregroundStyle(
            LinearGradient(
              colors: [
                Color.clear,
                Color.black.opacity(0.15),
                Color.black.opacity(0.1),
                Color.clear,
                Color.black.opacity(0.15),
                Color.black.opacity(0.1),
              ],
              startPoint: .topLeading,
              endPoint: .bottom
            )
          )
          .blur(radius: 1)
          .overlay {
            VStack(spacing: 6) {
              let items = entry.countdowns.prefix(7)
              
              ForEach(items.indices, id: \.self) { index in
                let countdown = items[index]
                let compact = compactDaysLeft(to: countdown.date)
                mediumWidgetRow(
                  icon: countdown.icon,
                  name: countdown.name,
                  date: formattedDate(date: countdown.date),
                  dateToEnd: "\(compact.value)",
                  compactFormat: "\(compact.unit)",
                  color: Color(hex: countdown.colorHex)
                )
                
                if index < items.count - 1 {
                  Divider()
                    .padding(.horizontal, 12)
                }
              }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)
          }
      }
    } else {
      VStack {
        Text("⭐️")
          .font(.system(size: 40, weight: .bold, design: .rounded))
        Text("Go premium".localized)
          .font(.system(size: 20, weight: .bold, design: .rounded))
          .foregroundColor(.primary)
      }
    }
  }
  
  func isExpired(_ date: Date) -> Bool {
    return date <= Date()
  }
  
  func compactDaysLeft(to target: Date, compactFormat: String = "Days") -> (value: Int, unit: String) {
    let now = Date()
    let seconds = Int(target.timeIntervalSince(now))
    
    let minutes = Int(ceil(Double(seconds) / 60))
    let hours = Int(ceil(Double(seconds) / 3600))
    let days = Int(ceil(Double(seconds) / 86400))
    
    switch compactFormat {
    case "Weeks":
      return (days / 7, "WEEKS".localized)
    case "Months":
      return (days / 30, "MONTHS".localized)
    case "Years":
      return (days / 365, "YEARS".localized)
    default:
      if seconds >= 86400 { return (days, "DAYS".localized) }
      if seconds >= 3600 { return (hours, "HOURS".localized) }
      if seconds >= 60 { return (minutes, "MIN".localized) }
    }
    
    return (seconds, "SECONDS".localized)
  }
  
  func formattedDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM yyyy"
    return formatter.string(from: date)
  }
}

struct mediumWidgetRow: View {
  
  let icon: String
  let name: String
  let date: String
  let dateToEnd: String
  let compactFormat: String
  let color: Color
  
  var body: some View {
    HStack {
      Text(icon)
        .font(.caption)
        .padding(7)
        .background(color)
        .clipShape(.rect(cornerRadius: 10))
        .shadow(color: .white, radius: 0.1, x: 0, y: 0)
      
      VStack(alignment: .leading) {
        Text(name)
          .font(.system(size: 14, weight: .semibold))
        Text(date)
          .font(.system(size: 10, weight: .light))
      }
      
      Spacer()
      
      VStack(alignment: .trailing ,spacing: 0) {
        
        if isExpired(Date.fromFormattedString(date)) {
          Image(systemName: "checkmark")
            .font(.system(size: 20))
            .foregroundColor(.primary)
        } else {
          VStack(alignment: .trailing ,spacing: 0) {
            
            Text(dateToEnd)
              .font(.system(size: 20, weight: .semibold))
            Text(compactFormat)
              .font(.system(size: 10, weight: .light))
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
  }
  
  func isExpired(_ date: Date) -> Bool {
    return date <= Date()
  }
}

struct MycountdownWidgetsExtension: Widget {
  let kind: String = "MycountdownWidgetsExtension"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
      MycountdownWidgetsExtensionEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
  }
}

extension SimpleEntry {
  static var sampleCountdown1: SimpleEntry {
    SimpleEntry(
      date: .now,
      countdowns: [WidgetCountdown(
        id: UUID(),
        name: "Birthday Party",
        date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
        icon: "🎂",
        colorHex: "#F97171"
      )]
    )
  }
  
  static var sampleCountdown2: SimpleEntry {
    SimpleEntry(
      date: .now,
      countdowns: [WidgetCountdown(
        id: UUID(),
        name: "Anniversary",
        date: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
        icon: "❤️",
        colorHex: "#FF6B6B"
      )]
    )
  }
}

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let r, g, b: UInt64
    switch hex.count {
    case 6: // RGB (24-bit)
      (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
    default:
      (r, g, b) = (1, 1, 0)
    }
    self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
  }
}

extension Date {
  static func fromFormattedString(_ string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM yyyy"
    return formatter.date(from: string) ?? Date()
  }
}
