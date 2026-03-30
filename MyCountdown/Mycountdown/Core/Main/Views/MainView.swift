//
//  MainView.swift
//  Mycountdown
//
//  Created by Danil Ovcharenko on 30.10.2025.
//

import SwiftUI
import SwiftData
import StoreKit

enum SortOption: String, CaseIterable, Codable {
    case upcoming
    case manualy
}

struct MainView: View {
    
    @Query(sort: \Countdown.date) private var allCountdowns: [Countdown]
    @Query(filter: #Predicate { !$0.isArchived }, sort: \Countdown.date) private var countdowns: [Countdown]
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject var store: StoreManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("sortOption") private var savedSortOption: String = SortOption.upcoming.rawValue
    @AppStorage("didRequestReview") private var didRequestReview = false
    @State private var sortOption: SortOption = .upcoming
    @State private var showingNewCountdown: Bool = false
    @State private var showSortPopover: Bool = false
    @State private var showImpExpPopover: Bool = false
    @State private var showDetailView: Bool = false
    @State private var selectedCountdown: Countdown? = nil    
    @State private var showPaywall: Bool = false
    
    @State private var showArchive = false
    private let textFieldName: String = "Search countdown..."
    @State private var showCalendarImport: Bool = false
    @State private var showExportAlert = false
    @State private var showCalendarOpenAlert = false
    private var shouldShowWidgetUpsell: Bool {
        !store.premiumUnlocked && allCountdowns.count >= 1
    }
    // computed arrays
    private var filteredUpcoming: [Countdown] {
        viewModel.filter(countdowns)
    }
    private var filteredManual: [Countdown] {
        viewModel.filter(viewModel.manualOrder)
    }
    
    var body: some View {
        NavigationStack {
            mainContent
        }
        .onChange(of: store.premiumUnlocked) { _, newValue in
            print("Premium changed", newValue)
        }
        .sheet(isPresented: $showPaywall) {
            if !store.premiumUnlocked {
                PaywallSheetContainer()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        .onAppear {
            sortOption = SortOption(rawValue: savedSortOption) ?? .upcoming
            viewModel.manualOrder = countdowns.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
        }
        .onChange(of: countdowns) { oldValue, newValue in
            viewModel.manualOrder = newValue.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
            viewModel.updateSelectedTagIfNeeded(countdowns: newValue)
        }
        .onChange(of: allCountdowns.count) { _, newCount in
            if newCount == 1 && !didRequestReview{
                requestReviewIfPossible()
                didRequestReview = true
            }
        }
        .onChange(of: sortOption) { oldValue, newValue in
            savedSortOption = newValue.rawValue
        }
        .onReceive(NotificationCenter.default.publisher(for: .openCountdownDetails)) { notification in
            if let id = notification.userInfo?["id"] as? UUID,
               let countdown = countdowns.first(where: { $0.id == id }) {
                selectedCountdown = countdown
                showDetailView = true
            }
        }
    }
}

extension MainView  {
    private var contentLayer: some View {
        VStack {
            header
            SearchBarView(searchText: $viewModel.searchText, textFieldName: textFieldName.localized)
            
            tagsSelection
            
            if shouldShowWidgetUpsell {
                widgetUpsellBanner
            }
            
            sortImpExpSection
            listSelection
        }
    }
    
    @ViewBuilder
    private var listSelection: some View {
        if countdowns.isEmpty {
            emptyCountdowns
            Spacer()
        } else if filteredUpcoming.isEmpty {
            emptySearchList
            Spacer()
        } else {
            switch sortOption {
            case .upcoming:
                upcomingSortedList(filteredUpcoming)
            case .manualy:
                manualSortedList(filteredManual)
            }
        }
    }
    
    @ViewBuilder
    private var tagsSelection: some View {
        let tags = viewModel.allTags(from: countdowns)
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TagButton(tag: "All", isSelected: viewModel.selectedTag == nil) {
                        withAnimation { viewModel.selectedTag = nil }
                    }
                    ForEach(viewModel.allTags(from: countdowns), id: \.self) { tag in
                        TagButton(tag: tag, isSelected: viewModel.selectedTag == tag) {
                            withAnimation { viewModel.selectedTag = tag }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
    
    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            contentLayer
            addCountdownButton
                .zIndex(1)
        }
        .background{
            if colorScheme == .light {
                Image("mainScreenBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            }
        }
        .hideKeyboardOnTap()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationDestination(isPresented: $showingNewCountdown, destination: {
            NewCountdown()
        })
        .navigationDestination(isPresented: $showDetailView, destination: {
            DetailLoadingView(countdown: $selectedCountdown)
        })
        .fullScreenCover(isPresented: $showArchive) {
            ArchiveView()
        }
        .alert("Export all countdowns to Calendar?",
               isPresented: $showExportAlert) {
            
            Button("Export".localized, role: .destructive) {
                viewModel.exportAllCountdownsToCalendar(allCountdowns)
                showCalendarOpenAlert = true
            }
            
            Button("Cancel".localized, role: .cancel) { }
            
        } message: {
            Text("Events will be added or updated in the existing “Countdowns” calendar.")
        }
        .alert("Export Successful",
               isPresented: $showCalendarOpenAlert) {
            
            Button("View in calendar", role: .destructive) {
                viewModel.openCalendar()
            }
            
            Button("OK", role: .cancel) { }
            
        } message: {
            Text("Events will be added or updated in the existing “Countdowns” calendar.")
        }
    }
    
    
    private var header: some View {
        HStack {
            Text("MyCountdown")
                .font(.system(size: 26 , weight: .semibold, design: .rounded))
            
            Spacer()
            
            if !store.premiumUnlocked {
                Button(action: {
                    showPaywall = true
                }) {
                    Text("PRO")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 76, height: 40)
                        .background(.proYellow)
                        .cornerRadius(20)
                        .shadow(color: .proYellow.opacity(0.5), radius: 6, x: 0, y: 4)
                }
            }
            
            Button(action: {
                showArchive.toggle()
            }) {
                withAnimation(.smooth) {
                    Image(.archiveIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .frame(width: 40, height: 40)
                        .background(.white)
                        .cornerRadius(20)
                        .shadow(color: .plusPink.opacity(0.5), radius: 6, x: 0, y: 4)
                }
            }
            
            Button(action: {
                if store.premiumUnlocked {
                    showingNewCountdown.toggle()
                } else {
                    if allCountdowns.count >= 4 {
                        showPaywall = true
                    } else {
                        showingNewCountdown.toggle()
                    }
                }
            }) {
                Image(.plusIcon)
                    .resizable()
                    .scaledToFit()
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
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var widgetUpsellBanner: some View {
        Button {
            showPaywall = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
            
                Text(String(format: "Unlock widgets for /month".localized , store.yearlyPackage?.storeProduct.yearEquivalent() ?? "--" ))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(spacing: 14) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("• 3-day free trial".localized)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("• No payment due now".localized)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Text("Get".localized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.green)
                        )
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1.5)
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var sortImpExpSection: some View {
        HStack {
            Button {
                showSortPopover.toggle()
            } label: {
                HStack(spacing: 4) {
                    Text("Sort".localized)
                    Text("▼")
                        .rotationEffect(.degrees(showSortPopover ? 180 : 0))
                        .animation(.smooth, value: showSortPopover)
                }
                .font(.system(size: 16, weight: .semibold, design: .default))
            }
            .popover(isPresented: $showSortPopover, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 40) {
                    Button {
                        sortOption = .upcoming
                        showSortPopover = false
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Sort by upcoming".localized)
                                .font(.system(size: 24, weight: .regular, design: .default))
                            if  sortOption == .upcoming {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                            }
                        }
                    }
                    
                    Button {
                        sortOption = .manualy
                        showSortPopover = false
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "pencil")
                            Text("Sort manualy".localized)
                                .font(.system(size: 24, weight: .regular, design: .default))
                            if  sortOption == .manualy {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                            }
                        }
                    }
                }
                .padding(25)
                .frame(maxWidth: .infinity)
                .presentationCompactAdaptation(.popover)
            }
            
            Spacer()
            
            Button {
                if store.premiumUnlocked {
                    showImpExpPopover.toggle()
                } else {
                    showPaywall = true
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Import / Export".localized)
                }
                .font(.system(size: 16, weight: .semibold, design: .default))
            }
            .popover(isPresented: $showImpExpPopover, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 40) {
                    Button {
                        showCalendarImport = true
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Import".localized)
                                .font(.system(size: 24, weight: .regular, design: .default))
                            
                        }
                    }
                    .fullScreenCover(isPresented: $showCalendarImport) {
                        ImportFromCalendarView(viewModel: CalendarImportViewModel(modelContext: modelContext))
                    }
                    
                    Button {
                        showExportAlert = true
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Export".localized)
                                .font(.system(size: 24, weight: .regular, design: .default))
                        }
                    }
                }
                .padding(25)
                .frame(maxWidth: .infinity)
                .presentationCompactAdaptation(.popover)
            }
        }
        .foregroundStyle(.primary)
        .padding(.top, viewModel.allTags(from: countdowns).isEmpty ? 16 : 0)
        .padding(.horizontal)
    }
    
    private var emptyCountdowns: some View {
        VStack(spacing: 0) {
            Image(.oopsEmpty)
                .resizable()
                .scaledToFit()
                .frame(width: 197, height: 109)
            
            Group {
                Text("You don't have any counters, click the ".localized)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(.searchBarGray)
                +
                Text("add button.".localized)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.searchBarGray)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .padding(.top, -10)
        }
        .padding(.top, 80)
    }
    
    private var emptySearchList: some View {
        VStack(spacing: 0) {
            Group {
                Text("You don't have any countdowns named: ")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                +
                Text(viewModel.searchText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .foregroundColor(.searchBarGray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
        }
        .padding(.top, 80)
    }
    
    private func segue(countdown: Countdown) {
        selectedCountdown = countdown
        showDetailView.toggle()
    }
    
    private func upcomingSortedList(_ countdowns: [Countdown]) -> some View {
        List {
            ForEach(countdowns, id: \.self) { countdown in
                CountdownRowView(countdown: countdown)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture {
                        segue(countdown: countdown)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .environment(\.editMode, .constant(.inactive))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        HStack {
                            Button {
                                withAnimation(.smooth) {
                                    countdown.isArchived = true
                                    try? modelContext.save()
                                }
                            } label: {
                                Circle()
                                    .frame(width: 48, height: 48)
                                    .foregroundStyle(.gray)
                                    .overlay {
                                        Image(systemName: "archivebox")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .scaledToFit()
                                            .foregroundStyle(.white)
                                    }
                                Text("Archive".localized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        HStack {
                            Button(role: .destructive) {
                                withAnimation(.smooth) {
                                    modelContext.delete(countdown)
                                    try? modelContext.save()
                                    viewModel.removeCountdownFromWidget(id: countdown.id)
                                }
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
            Color.clear
                .frame(height: 61)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
    
    private func requestReviewIfPossible() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive}) as? UIWindowScene
        else { return }
        
        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func manualSortedList(_ countdowns: [Countdown]) -> some View {
        List {
            ForEach(countdowns) { countdown in
                CountdownRowView(countdown: countdown)
                    .onTapGesture {
                        segue(countdown: countdown)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .environment(\.editMode, .constant(.active))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        HStack {
                            Button {
                                withAnimation(.smooth) {
                                    countdown.isArchived = true
                                    try? modelContext.save()
                                }
                            } label: {
                                Circle()
                                    .frame(width: 48, height: 48)
                                    .foregroundStyle(.gray)
                                    .overlay {
                                        Image(systemName: "archivebox")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .scaledToFit()
                                            .foregroundStyle(.white)
                                    }
                                Text("Archive".localized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        HStack {
                            Button(role: .destructive) {
                                withAnimation(.smooth) {
                                    modelContext.delete(countdown)
                                    try? modelContext.save()
                                    viewModel.removeCountdownFromWidget(id: countdown.id)
                                }
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
            .onMove { from, to in
                viewModel.moveItem(from: from, to: to, modelContext: modelContext)
            }
            Color.clear
                .frame(height: 61)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
    
    enum PaywallFlow {
        case preview
        case goPremium
    }
    
    struct PaywallSheetContainer: View {
        @Environment(\.dismiss) private var dismiss
        @State private var flow: PaywallFlow = .preview
        
        var body: some View {
            ZStack {
                switch flow {
                case .preview:
                    PaywallPreview(
                        onFinish: {
                            withAnimation(.easeInOut) {
                                flow = .goPremium
                            }
                        }
                    )
                    
                case .goPremium:
                    PaywallGoPremium(
                        onClose: {
                            dismiss()
                        }
                    )
                }
            }
        }
    }
    
    private var addCountdownButton: some View {
        Button(action: {
            if store.premiumUnlocked {
                showingNewCountdown.toggle()
            } else {
                if allCountdowns.count >= 5 {
                    showPaywall = true
                } else {
                    showingNewCountdown.toggle()
                }
            }
        }) {
            HStack {
                Spacer()
                Image(.plusIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text("Add Countdown".localized)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 61)
            .background(
                LinearGradient(
                    colors: [.plusBlue, .plusPink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .plusPink.opacity(0.75), radius: 6, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
}
