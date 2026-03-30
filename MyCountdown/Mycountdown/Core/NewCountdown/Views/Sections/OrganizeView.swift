//
//  OrganizeView.swift
//  Mycountdown
//
//  Created by Michael on 11/5/25.
//

import SwiftUI
import SwiftData
import Combine

struct OrganizeView: View {
    
    @Query(sort: \Countdown.date) private var countdowns: [Countdown]
    @Binding var tags: [String]
    @Binding var selectedTags: [String]
    @State private var newTag: String = ""
    @State private var emoji: String = "🏷️"
    @State private var emojiInput: String = ""
    @State private var showManageTags: Bool = false
    @FocusState private var isEmojiFieldFocused: Bool
    @StateObject private var tagManager = TagManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Organize".localized.uppercased())
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            
            VStack(alignment: .center, spacing: 16) {
                tagsGrid
                newTagButton
                if newTag.count > 15 {
                    Text("Tag name must be under 20 characters.")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .transition(.opacity)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.primaryBackgroundTheme)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            )
        }
        .padding(.horizontal)
        .sheet(isPresented: $showManageTags) {
            ManageTagsSheetView(tags: $tags, selectedTags: $selectedTags)
                .presentationDetents([.height(600)])
                .presentationDragIndicator(.hidden)
        }
    }
}

#Preview {
    OrganizeView(tags: .constant(["🎂 Birthdays"]), selectedTags: .constant([]))
}

//MARK: EXTENSION
extension OrganizeView {
    private var tagsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            Button {
                showManageTags.toggle()
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Manage Tags".localized)
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(6)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color(.tagsBackground))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                )
            }
            
            // MARK: - Tag Buttons
            ForEach(tagManager.allTags, id: \.self) { tag in
                Button {
                    toggleTagSelection(tag.displayName)
                } label: {
                    Text(tag.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .padding(6)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(.tagsBackground))
                                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        )
                        .foregroundColor(selectedTags.contains(tag.displayName) ? .accentColor : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var newTagButton: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 24))
                .shadow(
                    color: isEmojiFieldFocused ? .accent.opacity(0.5) : .clear,
                    radius: 3, x: 0, y: 2
                )
                .onTapGesture {
                    isEmojiFieldFocused = true
                }
            
            EmojiTextField(text: $emojiInput)
                .focused($isEmojiFieldFocused)
                .opacity(0)
                .frame(width: 0, height: 0)
                .onChange(of: emojiInput) { _, newValue in
                    guard let last = newValue.last else { return }
                    emoji = String(last)
                    emojiInput = ""
                }
            
            TextField("Add New Tag…".localized, text: $newTag)
                .keyboardType(.default)
                .autocorrectionDisabled(true)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .onReceive(Just(newTag)) { value in
                    let trimmed = String(value.prefix(15))
                    if trimmed != value {
                        newTag = trimmed
                    }
                }
            Button {
                let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmed.isEmpty else { return }
                
                tagManager.addTag(emoji: emoji, name: trimmed)
                
                newTag = ""
                emoji = "🏷️"
                emojiInput = ""
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accent)
                    .frame(width: 25, height: 25)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(.tagsBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .padding(.bottom, 8)
    }
    
    // MARK: Function
    private func toggleTagSelection(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
}
