//
//  ManageTagsSheetView.swift
//  Mycountdown
//
//  Created by Michael on 11/6/25.
//

import SwiftUI
import SwiftData
import Combine

struct ManageTagsSheetView: View {
  
  @Query(sort: \Countdown.date) private var countdowns: [Countdown]
  @Environment(\.dismiss) var dismiss
  
  @Binding var tags: [String]
  @Binding var selectedTags: [String]
  
  @StateObject private var tagManager = TagManager.shared
  @FocusState private var isEmojiFieldFocused: Bool
  @State private var showNewTag: Bool = false
  @State private var emojiTag: String = "🏷️"
  @State private var newTag: String = ""
  @State private var emojiInput: String = ""
  
  var body: some View {
    VStack(alignment: .center, spacing: 10) {
      header
      tagList
      if showNewTag {
        newTagsList
      }
      if newTag.count > 15 {
        Text("Tag name must be under 15 characters.")
          .font(.system(size: 14, weight: .regular, design: .default))
          .multilineTextAlignment(.center)
          .foregroundColor(.red)
          .padding(.horizontal)
          .transition(.opacity)
      }
      
      Spacer()
      
      CustomButton(
        action: {
          dismiss()
        },
        text: "Done".localized,
        frameWidth: 180,
        background: LinearGradient(
          colors: [Color.plusBlue.opacity(0.75),
                   Color.plusPink.opacity(0.75)],
          startPoint: .top,
          endPoint: .bottom
        ),
        textColor: .white,
        shadowColor: Color.borderPurple.opacity(0.2),
        borderColor: .borderPurple
      )
    }
    .hideKeyboardOnTap()
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .animation(.easeInOut, value: showNewTag)
    .padding()
    .padding(.horizontal)
  }
}

#Preview {
  ManageTagsSheetView(
    tags: .constant(["🎂 Birthdays", "🎉 Celebrations", "⏰ Reminders"]),
    selectedTags: .constant([])
  )
}

//MARK: EXTENSION
extension ManageTagsSheetView {
  private var header: some View {
    HStack {
      Image("Vector")
        .renderingMode(.template)
        .foregroundColor(Color.primary)
        .onTapGesture { dismiss() }
      Spacer()
      Text("Manage Tags".localized)
        .font(.system(size: 24, weight: .semibold))
      Spacer()
      Button {
        showNewTag.toggle()
      } label: {
        Image(.plusIcon)
          .resizable()
          .scaledToFit()
          .rotationEffect(.degrees(showNewTag ? 45 : 0))
          .frame(width: 16, height: 16)
          .frame(width: 40, height: 40)
          .background(
            LinearGradient(
              colors: [.plusBlue, .plusPink],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .cornerRadius(20)
          .shadow(color: .plusPink.opacity(0.5), radius: 6, x: 0, y: 4)
      }
    }
    .padding(.bottom)
  }
  
  private var tagList: some View {
    ForEach(tagManager.allTags, id: \.self) { tag in
      HStack {
        Image(systemName: "slider.horizontal.3")
          .foregroundStyle(.accent)
        Text(tag.displayName)
        Spacer()
        Button {
          withAnimation(.smooth) {
            tagManager.deleteTag(tag, countdowns: countdowns)
          }
        } label: {
          Image(systemName: "minus.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.red)
            .frame(width: 24, height: 24)
        }
      }
      .padding(8)
      .background(
        RoundedRectangle(cornerRadius: 7)
          .stroke(.borderGray, lineWidth: 0.3)
          .fill(Color(.systemBackground))
          .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 6)
      )
    }
  }
  
  private var newTagsList: some View {
    HStack(spacing: 6) {
      Image(systemName: "slider.horizontal.3")
        .foregroundStyle(.accent)
      
      Text(emojiTag)
        .font(.system(size: 24))
        .shadow(
          color: isEmojiFieldFocused ? .accent.opacity(0.75) : .clear,
          radius: 6, x: 0, y: 2
        )
        .onTapGesture { isEmojiFieldFocused = true }
      
      EmojiTextField(text: $emojiInput)
        .focused($isEmojiFieldFocused)
        .opacity(0)
        .frame(width: 0, height: 0)
        .onChange(of: emojiInput) { _, newValue in
          guard let last = newValue.last else { return }
          emojiTag = String(last)
          emojiInput = ""
        }
      
      TextField("Add a new tag...".localized, text: $newTag)
        .onReceive(Just(newTag)) { value in
            let trimmed = String(value.prefix(15))
            if trimmed != value {
                newTag = trimmed
            }
        }
      
      Spacer()
      
      Button {
        tagManager.addTag(emoji: emojiTag, name: newTag.trimmingCharacters(in: .whitespacesAndNewlines))
      } label: {
        Image(systemName: "plus.circle.fill")
          .resizable()
          .scaledToFit()
          .foregroundColor(.accent)
          .frame(width: 25, height: 25)
      }
    }
    .padding(8)
    .background(
      RoundedRectangle(cornerRadius: 7)
        .stroke(.borderGray, lineWidth: 0.3)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 6)
    )
    .transition(.push(from: .bottom))
  }
}
