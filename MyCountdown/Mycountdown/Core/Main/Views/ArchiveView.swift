//
//  ArchiveView.swift
//  Mycountdown
//
//  Created by Michael on 11/14/25.
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
  
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) var dismiss
  @Environment(\.modelContext) private var context
  @Query(filter: #Predicate { $0.isArchived }, sort: \Countdown.date)
  private var archived: [Countdown] = []
  
  var body: some View {
    VStack {
      header
      if archived.isEmpty {
        VStack(spacing: 0) {
          Image(.oopsEmpty)
            .resizable()
            .scaledToFit()
            .frame(width: 197, height: 109)
          
          Group {
            Text("You don't have any archived counters, click the ".localized)
              .font(.system(size: 24, weight: .regular, design: .rounded))
              .foregroundColor(.searchBarGray)
            +
            Text("back button.".localized)
              .font(.system(size: 24, weight: .bold, design: .rounded))
              .foregroundColor(.searchBarGray)
          }
          .multilineTextAlignment(.center)
          .padding(.horizontal, 30)
          .padding(.top, -10)
          Spacer()
        }
        .padding(.top, 180)
      } else {
        List {
          ForEach(archived, id: \.self) { item in
            CountdownRowView(countdown: item)
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
              .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
              .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                HStack {
                  Button {
                    withAnimation {
                      item.isArchived = false
                      try? context.save()
                    }
                  } label: {
                    Circle()
                      .frame(width: 75, height: 75)
                      .foregroundStyle(.gray)
                      .overlay {
                        Image(systemName: "archivebox")
                          .resizable()
                          .frame(width: 24, height: 24)
                          .scaledToFit()
                          .foregroundStyle(.white)
                      }
                    Text("Unarchive".localized)
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                }
              }
              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                HStack {
                  Button(role: .destructive) {
                      context.delete(item)
                  } label: {
                    Circle()
                      .frame(width: 48, height: 48)
                      .foregroundStyle(.red)
                      .overlay {
                        Image(systemName: "trash")
                          .resizable()
                          .frame(width: 24, height: 24)
                          .scaledToFit()
                          .foregroundStyle(.white)
                      }
                    Text("Delete".localized)
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                }
              }
          }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
      }
    }
    .background{
      if colorScheme == .light {
        Image("mainScreenBackground")
          .resizable()
          .scaledToFill()
          .ignoresSafeArea(.all)
      }
    }
  }
}

#Preview {
  ArchiveView()
}

extension ArchiveView {
  private var header: some View {
    HStack {
      Image("Vector")
        .renderingMode(.template)
        .foregroundColor(Color.primary)
        .onTapGesture {
          dismiss.callAsFunction()
        }
      Spacer()
      Text("Countdowns".localized)
        .font(.system(size: 24, weight: .semibold, design: .default))
      Spacer()
      Image("Vector")
        .opacity(0)
    }
    .padding()
  }
}
