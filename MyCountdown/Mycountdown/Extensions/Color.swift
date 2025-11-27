//
//  Color.swift
//  Mycountdown
//
//  Created by Michael on 11/7/25.
//

import Foundation
import SwiftUI

extension Color {
  func toHexString() -> String {
    let uiColor = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return String(format: "#%02lX%02lX%02lX",
                  lroundf(Float(red * 255)),
                  lroundf(Float(green * 255)),
                  lroundf(Float(blue * 255)))
  }
  
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >> 8) & 0xFF) / 255.0
    let b = Double(rgb & 0xFF) / 255.0
    
    self.init(red: r, green: g, blue: b)
  }
  
  func gradientPair() -> [Color] {
    return [.white, self]
  }
}
