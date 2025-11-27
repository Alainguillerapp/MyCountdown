//
//  PickExpansesFormatViewModel.swift
//  Mycountdown
//
//  Created by Michael on 11/6/25.
//

import Foundation
import SwiftUI
import Combine

final class PickExpansesFormatViewModel: ObservableObject {
  
  @Published private var targetDate: Date = Date()
  @Published private var selectedUnits: [String] = []

  private var timer: AnyCancellable?
  
  init() {

    startTimer()
  }
  
  private func startTimer() {
    timer = Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
  }
  
  func timeRemaining(selectedUnits: [String], date: Date) -> [String: Int] {
    var remainingSeconds = max(0, Int(date.timeIntervalSince(Date())))
    var result: [String: Int] = [:]
    
    let conversions: [(String, Int)] = [
      ("Years".localized, 31_536_000),
      ("Months".localized, 2_592_000),
      ("Weeks".localized, 604_800),
      ("Days".localized, 86_400),
      ("Hours".localized, 3_600),
      ("Minutes".localized, 60),
      ("Seconds".localized, 1)
    ]
    
    for (unit, secondsInUnit) in conversions {
      if selectedUnits.contains(unit) {
        result[unit] = remainingSeconds / secondsInUnit
        remainingSeconds %= secondsInUnit
      }
    }
    
    if Int(date.timeIntervalSince(Date())) <= 0 {
      let lastThreeUnits = ["Hours".localized, "Minutes".localized, "Seconds".localized]
      for unit in lastThreeUnits where selectedUnits.contains(unit) {
        result[unit] = 0
      }
    }
    return result
  }
  
  func unitOrder(_ a: String, _ b: String) -> Bool {
    let order = ["Years".localized, "Months".localized, "Weeks".localized, "Days".localized, "Hours".localized, "Minutes".localized, "Seconds".localized]
      let indexA = order.firstIndex(of: a) ?? Int.max
      let indexB = order.firstIndex(of: b) ?? Int.max
      
      return indexA < indexB
  }
  
  func boxWidth(for value: Int) -> CGFloat {
    let base: CGFloat
    switch selectedUnits.count {
    case 1: base = 140
    case 2: base = 100
    case 3: base = 78
    case 4: base = 66
    default: base = 56
    }
    
    let digits = String(abs(value)).count
    let extra = CGFloat(max(0, digits - 2)) * 25.0
    return base + extra
  }
  
  var numberFontSize: CGFloat {
    switch selectedUnits.count {
    case 1: return 60
    case 2: return 55
    case 3: return 45
    case 4: return 35
    default: return 30
    }
  }
  
  var labelFontSize: CGFloat {
    switch selectedUnits.count {
    case 1: return 22
    case 2: return 18
    case 3: return 14
    default: return 12
    }
  }
  
  var numberBoxHeight: CGFloat {
    numberFontSize * 1.4
  }
}
