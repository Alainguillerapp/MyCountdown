//
//  PickCompactFormatView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI

struct PickCompactFormatView: View {
  
  @EnvironmentObject var store: StoreManager
  @Binding var selectedFormat: String
  private let formats = ["Days".localized, "Weeks".localized, "Months".localized, "Years".localized]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {      
      if !store.premiumUnlocked {
          
          Group {
              Text("Pick compact format - premium".localized.uppercased())
              +
              Text(" ⭐️")
          }
          .font(.system(size: 15, weight: .semibold, design: .rounded))
      } else {
        Text("Pick compact format".localized.uppercased())
          .font(.system(size: 15, weight: .semibold, design: .rounded))
      }
      
      VStack {
        Picker("Compact format", selection: $selectedFormat) {
          ForEach(formats, id: \.self) { format in
            Text(format).tag(format)
          }
        }
        .pickerStyle(.palette)
        .padding()
        .disabled(!store.premiumUnlocked)
        
          Group {
              Text("Will show time remaining in ".localized)
              +
              Text("\(selectedFormat)".localized)
          }
          .foregroundStyle(.searchBarGray)
          .padding(.horizontal)
          .padding(.bottom)
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
  PickCompactFormatView(selectedFormat: .constant("Days"))
}
