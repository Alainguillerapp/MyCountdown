//
//  SelectIconView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI

struct SelectIconView: View {
  
  @Binding var selectedEmoji: String
  @FocusState private var isEmojiFieldFocused: Bool
  @State private var emojiInput: String = ""
  @State private var customEmoji: String? = nil
  
  private let emojis = ["🎵", "🚀", "📅", "🎪", "🏀", "💎", "🧘🏾"]
  private let columns = [
    GridItem( .flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Select icon".localized.uppercased())
        .font(.system(size: 15, weight: .semibold, design: .rounded))
      
      LazyVGrid(columns: columns, spacing: 20) {
        iconsGrid
        plusIcon
      }
    }
    .padding(.horizontal)
  }
}

#Preview {
  SelectIconView(selectedEmoji: .constant(""))
}

// MARK: EXTENSION
extension SelectIconView {
  private var iconsGrid: some View {
    ForEach(emojis, id: \.self) { emoji in
      ZStack {
        RoundedRectangle(cornerRadius: 20)
          .fill(.clear)
          .frame(width: 76, height: 76)
          .overlay {
            RoundedRectangle(cornerRadius: 20)
              .stroke(
                selectedEmoji == emoji ? Color.accentColor : Color.searchBarGray,
                lineWidth: selectedEmoji == emoji ? 2 : 1
              )
          }
        
        Text(emoji)
          .font(.system(size: 33))
      }
      .onTapGesture {
        withAnimation {
          selectedEmoji = emoji
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(.systemBackground))
          .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
      )
    }
  }
  
  private var plusIcon: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(.clear)
        .frame(width: 76, height: 76)
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(.plusPink, lineWidth: 1)
        )
      
      if let emoji = customEmoji {
        ZStack {
          RoundedRectangle(cornerRadius: 20)
            .fill(.clear)
            .frame(width: 76, height: 76)
            .overlay {
              RoundedRectangle(cornerRadius: 20)
                .stroke(
                  selectedEmoji == customEmoji ? Color.accentColor : Color.plusPink,
                  lineWidth: selectedEmoji == customEmoji ? 2 : 1
                )
            }
          
          Text(emoji)
            .font(.system(size: 33))
            .onTapGesture {
              isEmojiFieldFocused = true
            }
        }
      } else {
        Image(systemName: "plus")
          .font(.system(size: 27, weight: .bold))
          .foregroundStyle(.plusPink)
          .onTapGesture {
            isEmojiFieldFocused = true
          }
      }
      
      // Hidden emoji-only text field
      EmojiTextField(text: $emojiInput)
        .focused($isEmojiFieldFocused)
        .opacity(0)
        .frame(width: 0, height: 0)
        .onChange(of: emojiInput) { oldValue, newValue in
          if let last = newValue.last, last.isEmoji {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              withAnimation(.easeInOut) {
                customEmoji = String(last)
                selectedEmoji = customEmoji ?? ""
              }
              emojiInput = ""
              isEmojiFieldFocused = false
            }
          } else {
            emojiInput = ""
          }
        }
    }
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    )
  }
}
