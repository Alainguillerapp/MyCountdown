//
//  CountdownDateView.swift
//  Mycountdown
//
//  Created by Michael on 11/11/25.
//

import SwiftUI

struct CountdownDateView: View {
  
  @StateObject private var viewModel = PickExpansesFormatViewModel()
  @Binding var selectedUnits: [String]
  @Binding var targetDate: Date
  
  var body: some View {
    let remaining = viewModel.timeRemaining(selectedUnits: selectedUnits, date: targetDate)
    let sortedUnits = selectedUnits.sorted(by: viewModel.unitOrder)
    let splitIndex = max(0, sortedUnits.count - 3)
    let topUnits = Array(sortedUnits.prefix(splitIndex))
    let bottomUnits = Array(sortedUnits.suffix(from: splitIndex))
    
    VStack(spacing: 0) {
      if !topUnits.isEmpty {
        HStack(spacing: 0) {
          ForEach(topUnits, id: \.self) { unit in
            if let value = remaining[unit] {
              unitBlock(value: value, unit: unit)
            }
          }
        }
        .padding(.top, -10)
      }
      
      HStack(spacing: 0) {
        ForEach(bottomUnits, id: \.self) { unit in
          if let value = remaining[unit] {
            unitBlock(value: value, unit: unit)
          }
        }
      }
    }
    .padding()
    .padding(.horizontal)
    .background(
      LinearGradient(
        colors: [
          .expansesBlue.opacity(0.6),
          .expansesGreen.opacity(0.6),
          .expansesOrange.opacity(0.6)
        ],
        startPoint: .leading,
        endPoint: .trailing
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: 24))
    .shadow(color: .searchBarGray, radius: 1, x: 0, y: 1)
  }
  
  @ViewBuilder
  private func unitBlock(value: Int, unit: String) -> some View {
    VStack(spacing: 0) {
      Text("\(value)")
        .font(.system(size: viewModel.numberFontSize, weight: .bold, design: .rounded))
        .monospacedDigit()
        .lineLimit(1)
        .allowsTightening(true)
        .frame(width: viewModel.boxWidth(for: value), height: viewModel.numberBoxHeight)
        .id("\(unit)-\(value)")
      
      Text(unit.lowercased())
        .font(.system(size: viewModel.labelFontSize, weight: .semibold))
        .foregroundStyle(.white.opacity(0.95))
    }
    .padding(4)
    .foregroundStyle(.white)
    .layoutPriority(1)
    .animation(.smooth, value: selectedUnits)
  }
}

struct CountdownDateView_Previews: PreviewProvider {
  
  @State static var units: [String] = ["Days", "Hours", "Minutes", "Seconds"]
  @State static var date: Date = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
  
  static var previews: some View {
    CountdownDateView(
      selectedUnits: $units,
      targetDate: $date
    )
    .padding()
    .previewLayout(.sizeThatFits)
  }
}
