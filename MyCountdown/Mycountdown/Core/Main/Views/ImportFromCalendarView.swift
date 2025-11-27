//
//  ImportFromCalendarView.swift
//  Mycountdown
//
//  Created by Michael on 11/19/25.
//

import SwiftUI

struct ImportFromCalendarView: View {
  
  @Environment(\.dismiss) var dismiss
  @ObservedObject var viewModel: CalendarImportViewModel
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(viewModel.importedEvents, id: \.uniqueID) { event in
          HStack {
            Text(event.title ?? "No title")
            Spacer()
            if viewModel.selectedEventIDs.contains(event.eventIdentifier) {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            } else {
              Image(systemName: "circle")
                .foregroundColor(.gray)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewModel.toggleSelection(event)
          }
        }
      }
      .navigationTitle("Select Events")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Import") {
            viewModel.importSelectedEvents()
            dismiss()
          }
        }
        
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
    .task {
      await viewModel.loadEvents()
    }
  }
}
