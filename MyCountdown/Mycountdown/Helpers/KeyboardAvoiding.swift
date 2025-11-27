//
//  KeyboardAvoiding.swift
//  Mycountdown
//
//  Created by Michael on 11/20/25.
//

import Foundation
import Combine
import SwiftUI

struct KeyboardAvoiding: ViewModifier {
  let inset: CGFloat
  @State private var keyboardPadding: CGFloat = .zero
  
  private var keyboardPublisher: AnyPublisher<Bool, Never> {
    Publishers.Merge(
      NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { _ in true },
      
      NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in false }
    )
    .eraseToAnyPublisher()
  }
  
  func body(content: Content) -> some View {
    content
      .safeAreaInset(edge: .bottom) {
        EmptyView()
          .frame(height: keyboardPadding)
      }
      .onReceive(keyboardPublisher) { isPresented in
        keyboardPadding = isPresented ? inset : .zero
      }
  }
}
