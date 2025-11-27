//
//  PickExpansesFormatView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI

struct PickExpansesFormatView: View {

  @EnvironmentObject var store: StoreManager
  @Binding var selectedUnits: [String]
  @Binding var sameFormatWidget: Bool
  @Binding var targetDate: Date
  private let allUnits = ["Years".localized, "Months".localized, "Weeks".localized, "Days".localized, "Hours".localized, "Minutes".localized, "Seconds".localized]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      if !store.premiumUnlocked {
          
          
          Group {
              Text("Pick expanses format - premium".localized.uppercased())
              +
              Text(" ⭐️")
          }
          .font(.system(size: 15, weight: .semibold, design: .rounded))
      } else {
        Text("Pick expanses format - premium".localized.uppercased())
          .font(.system(size: 15, weight: .semibold, design: .rounded))
      }
      
      VStack(spacing: 20) {
        CountdownDateView(selectedUnits: $selectedUnits, targetDate: $targetDate)
          .padding(.top)
        formats
          .allowsHitTesting(store.premiumUnlocked)
          .opacity(store.premiumUnlocked ? 1 : 0.5)
        toggle
          .allowsHitTesting(store.premiumUnlocked)
      }
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.primaryBackgroundTheme)
          .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
      )
    }
    .padding(.horizontal)
  }
}

#Preview {
  StatefulPreviewWrapper(["Hours", "Minutes", "Seconds"]) {
    PickExpansesFormatView(selectedUnits: $0, sameFormatWidget: .constant(true), targetDate: .constant(Date()))
      .environmentObject(StoreManager.init())
  }
}

// MARK: - Extension preview
extension PickExpansesFormatView {
  private var formats: some View {
    VStack(spacing: 24) {
      let firstRow = Array(allUnits.prefix(4))
      let secondRow = Array(allUnits.suffix(3))
      
      HStack(spacing: 30) {
        ForEach(firstRow, id: \.self) { unit in
          timeUnitCircle(for: unit)
        }
      }
      HStack(spacing: 36) {
        ForEach(secondRow, id: \.self) { unit in
          timeUnitCircle(for: unit)
        }
      }
    }
    .frame(maxWidth: .infinity)
  }
  
  private var toggle: some View {
    Toggle(isOn: $sameFormatWidget) {
      VStack(alignment: .leading, spacing: 4) {
        Text("Use Same Format in Small Widget".localized)
          .font(.system(size: 16, weight: .bold, design: .rounded))
        Text("(seconds not supported)".localized)
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }
    }
    .tint(.accentColor)
    .padding(.horizontal)
    .padding(.bottom)
  }
  
  private func timeUnitCircle(for unit: String) -> some View {
    VStack(spacing: 8) {
      ZStack {
        Circle()
          .fill(.primaryBackgroundTheme)
          .frame(width: 50, height: 50)
          .overlay {
            Circle()
              .stroke(.black, lineWidth: 2)
          }
        
        if selectedUnits.contains(unit) {
          Image("CheckmarkIcon")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(Color.primary)
            .frame(width: 24, height: 24)
            
        }
      }
      Text(unit)
        .font(.system(size: 14, weight: .medium))
    }
    .onTapGesture {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
        toggleUnit(unit)
      }
    }
  }
  
  private func toggleUnit(_ unit: String) {
    if selectedUnits.contains(unit) {
      if selectedUnits.count > 1 {
        selectedUnits.removeAll { $0 == unit }
      }
    } else {
      selectedUnits.append(unit)
    }
  }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
  @State var value: Value
  var content: (Binding<Value>) -> Content
  
  init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
    _value = State(initialValue: value)
    self.content = content
  }
  var body: some View {
    content($value)
  }
}

