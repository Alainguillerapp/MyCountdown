//
//  TagButton.swift
//  Mycountdown
//
//  Created by Michael on 11/18/25.
//

import SwiftUI

struct TagButton: View {
  
  let tag: String
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Text(tag)
      .font(.system(size: 14, weight: .semibold))
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
      .foregroundColor(isSelected ? .white : .primary)
      .clipShape(Capsule())
      .onTapGesture { action() }
  }
}

#Preview {
  TagButton(tag: "", isSelected: true, action: { })
}
