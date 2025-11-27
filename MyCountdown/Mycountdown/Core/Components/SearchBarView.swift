//
//  SearchBarView.swift
//  Mycountdown
//
//  Created by Michael on 11/10/25.
//

import SwiftUI

struct SearchBarView: View {
  
  @Binding var searchText: String
  @State var textFieldName: String
  
  var body: some View {
    HStack(spacing: 8) {
      Image(.searchingGlass)
        .resizable()
        .frame(width: 19, height: 19)
        .padding(.leading)
      
      TextField(textFieldName, text: $searchText)
        .padding(.trailing, 40)
        .font(.system(size: 18, weight: .regular, design: .rounded))
        .foregroundColor(.searchBarGray)
        .overlay(alignment: .trailing) {
          Image(systemName: "xmark.circle.fill")
            .padding()
            .offset(x: 5) // for tapGasture
            .foregroundStyle(.searchBarGray)
            .opacity(searchText.isEmpty ? 0.0 : 1.0)
            .onTapGesture {
              UIApplication.shared.endEditing()
              searchText = ""
            }
        }
        .padding(.vertical, 10)
    }
    .frame(height: 47)
    .background(.tagsBackground)
    .cornerRadius(20)
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color.black.opacity(0.2), lineWidth: 0.2)
    )
    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
    .padding(.horizontal)
  }
}

#Preview {
  SearchBarView(searchText: .constant("Hello, world!"), textFieldName: "Type here...")
}
