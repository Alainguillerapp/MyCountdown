//
//  NewCountdown.swift
//  Mycountdown
//
//  Created by Michael on 11/4/25.
//

import SwiftUI
import SwiftData

struct NewCountdown: View {
  
  @EnvironmentObject var store: StoreManager
  @StateObject private var viewModel: NewCountdownViewModel
  @Environment(\.dismiss) var dismiss
  @Environment(\.modelContext) private var context
  @Environment(\.colorScheme) private var colorScheme
  @State private var now: Date = .now
  
  private let textFieldName: String = "e.g., Summer Festival".localized
  private let isEditing: Bool
  private var existingCountdown: Countdown?
  
  // Create new
  init() {
    _viewModel = StateObject(wrappedValue: NewCountdownViewModel(mode: .creating))
    self.isEditing = false
  }
  
  // Edit existing
  init(countdown: Countdown) {
    _viewModel = StateObject(wrappedValue: NewCountdownViewModel(mode: .editing(countdown)))
    self.isEditing = true
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      VStack(spacing: 0) {
        if !viewModel.name.isEmpty {
          VStack {
            header
            preview(proxy: proxy)
          }
          .zIndex(1)
        }
        ScrollView {
          VStack(spacing: 20) {
            if viewModel.name.isEmpty { header }
            eventName
            SelectIconView(selectedEmoji: $viewModel.emoji)
              .id("selectIconSection")
            PickADateView(
              selectedDate: $viewModel.date,
              weekdaysOnly: $viewModel.weekdaysOnly,
              allDay: $viewModel.allDay,
              time: $viewModel.time
            )
            .id("pickADateSection")
            PickATimeView(
              allDay: $viewModel.allDay,
              time: $viewModel.time,
              selectedDate: $viewModel.date
            )
            PickAColorView(selectedColor: $viewModel.color, userSelectedColor: $viewModel.userSelectedColor)
              .id("pickAColorSection")
            PickCompactFormatView(selectedFormat: $viewModel.compactFormat)
            PickExpansesFormatView(
              selectedUnits: $viewModel.selectedUnits,
              sameFormatWidget: $viewModel.sameFormatWidget,
              targetDate: viewModel.previewDateBinding
            )
            RemindMeView(
              countdownFinishesRemind: $viewModel.remindWhenFinished,
              dayBeforeRemind: $viewModel.remindDayBefore,
              weekBeforeRemind: $viewModel.remindWeekBefore
            )
            OrganizeView(tags: $viewModel.tags, selectedTags: $viewModel.selectedTags)
              .id("selectTagSection")
            buttons(proxy: proxy)
          }
        }
        .environmentObject(viewModel)
        .environmentObject(store)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden(true)
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
  NewCountdown()
    .environmentObject(StoreManager.init())
  
}

//MARK: EXTENSION
extension NewCountdown {
  private var header: some View {
    HStack {
      Image("Vector")
        .renderingMode(.template)
        .foregroundColor(Color.primary)
        .onTapGesture {
          dismiss.callAsFunction()
        }
      Spacer()
      Text(isEditing ? "Countdown".localized : "New Countdown".localized)
        .font(.system(size: 24, weight: .semibold, design: .default))
      Spacer()
      Image("Vector")
        .opacity(0)
    }
    .padding()
  }
  
  private var eventName: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Event name".localized.uppercased())
        .padding(.horizontal)
        .font(.system(size: 16, weight: .semibold, design: .rounded))
      
      SearchBarView(searchText: $viewModel.name, textFieldName: textFieldName)
        .onChange(of: viewModel.name, { oldValue, newValue in
          if newValue.count > 40 {
            viewModel.name = String(newValue.prefix(40))
          }
        })
        .background(
          RoundedRectangle(cornerRadius: 20)
            .stroke(viewModel.showNameError ? Color.red : Color.clear, lineWidth: viewModel.showNameError ? 2 : 0)
            .padding(.horizontal)
        )
      
      if viewModel.showNameError {
        Text("This field is required.".localized)
          .font(.system(size: 14, weight: .regular, design: .default))
          .foregroundColor(.red)
          .padding(.horizontal)
          .transition(.opacity)
      } else {
        Text("Give your countdown a meaningful name".localized)
          .font(.system(size: 18, weight: .regular, design: .default))
          .foregroundStyle(.searchBarGray)
          .padding(.horizontal)
      }
    }
    .id("eventNameSection")
  }
  
  private func buttons(proxy: ScrollViewProxy) -> some View {
    HStack(alignment: .center, spacing: 30) {
      CustomButton(
        action: {
          dismiss.callAsFunction()
        }, text: "Cancel".localized,
        frameWidth: .infinity,
        background:  LinearGradient(
          colors: [
            Color.white.opacity(0.25),
            Color.white.opacity(0.05),
            Color.clear,
            Color.white.opacity(0.15)
          ],
          startPoint: .top,
          endPoint: .bottom
        ),
        textColor: .primary,
        shadowColor: Color.searchBarGray.opacity(0.2),
        borderColor: .searchBarGray)
      
      CustomButton(
        action: {
          if viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
            viewModel.showNameError = true
            withAnimation(.smooth) { proxy.scrollTo("eventNameSection", anchor: .top) }
          } else {
            viewModel.save(context: context)
            dismiss.callAsFunction()
          }
        }, text: isEditing ? "Done".localized : "Create".localized,
        frameWidth: .infinity,
        background: LinearGradient(
          colors: [
            Color.plusBlue.opacity(0.75),
            Color.plusPink.opacity(0.75)
          ],
          startPoint: .top,
          endPoint: .bottom
        ),
        textColor: .white,
        shadowColor: Color.borderPurple.opacity(0.2),
        borderColor: .borderPurple
      )
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
  }
  
  private func preview(proxy: ScrollViewProxy) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      
      Text("Preview".localized)
        .font(.system(size: 16, weight: .semibold, design: .rounded))
      
      HStack(alignment: .center, spacing: 0) {
        // MARK: - Icon plus Name
        RoundedRectangle(cornerRadius: 20)
          .fill(viewModel.previewColor(modelContext: context).opacity(0.2))
          .frame(width: 72, height: 72)
          .overlay {
            Text(viewModel.emoji)
              .font(.system(size: 34))
          }
          .onTapGesture {
            withAnimation(.smooth) { proxy.scrollTo("selectIconSection", anchor: .top) }
          }
        
        Text(viewModel.name)
          .font(.system(size: 20, weight: .semibold, design: .rounded))
          .lineLimit(2)
          .foregroundColor(.primary)
          .padding(.leading)
          .onTapGesture {
            withAnimation(.smooth) { proxy.scrollTo("eventNameSection", anchor: .top) }
          }
        
        Spacer()
        
        if let firstTag = viewModel.selectedTags.first, let firstChar = firstTag.first {
          Text(String(firstChar))
            .font(.system(size: 18, weight: .semibold))
            .padding(6)
            .background(
              RoundedRectangle(cornerRadius: 30)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .padding(.trailing)
            .onTapGesture {
              withAnimation(.smooth) { proxy.scrollTo("selectTagSection", anchor: .bottom) }
            }
        }
          
          if viewModel.buildFinalDate() < Date() {
            RoundedRectangle(cornerRadius: 20)
              .fill(.white)
              .frame(width: 72, height: 72)
              .overlay {
                VStack(spacing: 0) {
                  Image(.checkmarkIcon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(viewModel.previewColor(modelContext: context))
                }
              }
              .overlay(
                RoundedRectangle(cornerRadius: 20)
                  .stroke(viewModel.previewColor(modelContext: context), lineWidth: 2)
              )
              .onTapGesture {
                withAnimation(.smooth) { proxy.scrollTo("pickADateSection", anchor: .center) }
            }
          } else {
            daysLeftSection
              .onTapGesture {
                  withAnimation(.smooth) { proxy.scrollTo("pickADateSection", anchor: .center) }
              }
          }
      }
      .padding()
      .background(
        ZStack(alignment: .top) {
          RoundedRectangle(cornerRadius: 20)
            .fill(viewModel.previewColor(modelContext: context).opacity(0.1))
            .onTapGesture {
              withAnimation(.smooth) { proxy.scrollTo("pickAColorSection", anchor: .top) }
            }
          
          RoundedRectangle(cornerRadius: 20)
            .fill(viewModel.previewColor(modelContext: context))
            .frame(height: 6)
            .clipShape(RoundedCorners(topLeft: 25, topRight: 25))
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(Color.borderRow, lineWidth: 1)
      )
      .padding(.top, 6)
    }
    .padding(.horizontal)
    .padding(.bottom)
  }
  
  private var daysLeftSection: some View {
    let display = compactDisplay
    
    return RoundedRectangle(cornerRadius: 20)
      .fill(.white)
      .frame(width: 72, height: 72)
      .overlay {
        VStack(spacing: 0) {
          Text("\(display.value)")
            .font(.system(size: 26, weight: .semibold))
            .minimumScaleFactor(0.4)
            .foregroundStyle(viewModel.previewColor(modelContext: context))
          
          Text(display.unit)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.gray)
        }
      }
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(Color(viewModel.previewColor(modelContext: context)), lineWidth: 2)
      )
  }
  
  private var compactDisplay: (value: Int, unit: String) {
    let target = viewModel.buildFinalDate()
    let seconds = Int(target.timeIntervalSince(now))
    
    let minutes = Int(ceil(Double(seconds) / 60))
    let hours = Int(ceil(Double(seconds) / 3600))
    let days = Int(ceil(Double(seconds) / 86400))
    
    
    switch viewModel.compactFormat {
        
    case "Weeks".localized:
      let weeks =  days / 7
      return (weeks, "WEEKS".localized)
      
    case "Months".localized:
      let months = days / 30
      return (months, "MONTHS".localized)
      
    case "Years".localized:
      let years = days / 365
        return (years, "YEARS".localized)
      
    default:
      if seconds >= 86400 {
        return (days, "DAYS".localized)
      }
      
      if seconds >= 3600 {
        return (hours, "HOURS".localized)
      }
      
      if seconds >= 60 {
        return (minutes, "MINUTES".localized)
      }
    }
    return (seconds, "SECONDS".localized)
  }
}
