//
//  View.swift
//  Mycountdown
//
//  Created by Michael on 11/10/25.
//

import Foundation
import SwiftUI

extension View {
  func hideKeyboardOnTap() -> some View {
    self.simultaneousGesture(
      TapGesture().onEnded {
        UIApplication.shared.sendAction(
          #selector(UIResponder.resignFirstResponder),
          to: nil,
          from: nil,
          for: nil
        )
      }
    )
  }
  
  func keyboardAvoiding(_ inset: CGFloat) -> some View {
    modifier(KeyboardAvoiding(inset: inset))
  }
}
