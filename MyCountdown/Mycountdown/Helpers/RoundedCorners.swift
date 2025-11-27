//
//  RoundedCorners.swift
//  Mycountdown
//
//  Created by Michael on 11/7/25.
//

import Foundation
import SwiftUI

struct RoundedCorners: Shape {
  
  var topLeft: CGFloat = 0
  var topRight: CGFloat = 0
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
    path.addQuadCurve(
      to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
      control: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
      control: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}
