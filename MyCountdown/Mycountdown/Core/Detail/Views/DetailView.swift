//
//  DetailView.swift
//  Mycountdown
//
//  Created by Michael on 11/11/25.
//

import SwiftUI
import SwiftData

struct DetailLoadingView: View {
    
    @Binding var countdown: Countdown?
    
    var body: some View {
        ZStack{
            if let countdown = countdown {
                DetailView(countdown: countdown)
            }
        }
    }
}

struct DetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var store: StoreManager
    @StateObject private var viewModel: DetailViewModel
    @State private var showDeleteAlert: Bool = false
    @State private var showEditView: Bool = false
    @State private var showMoreDialog: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showNote: Bool = false
    @State private var showDuplicateMessage: Bool = false
    @State private var showArchivedMessage: Bool = false
    @State private var showPaywall: Bool = false
    @State private var note: String
    @State private var noteHeight: CGFloat = 0
    @State private var lastNoteHeight: CGFloat = 0
    
    
    init (countdown: Countdown) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(countdown: countdown))
        _note = State(initialValue: countdown.note ?? "")
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    header
                    title
                    tags
                    CountdownDateView(selectedUnits: $viewModel.countdown.selectedUnits, targetDate: $viewModel.countdown.date)
                    if showNote {
                        TextField("Here can be your note", text: $note, axis: .vertical)
                            .id("NOTE_FIELD")
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .padding(.vertical)
                            .foregroundStyle(.noteGray)
                            .background(
                                Color(hex: viewModel.countdown.colorHex ?? "#FBC024")?.opacity(0.25) ?? .clear
                            )
                            .clipShape(.rect(cornerRadius: 25))
                            .frame(width: 330)
                            .shadow(color: .noteGray.opacity(0.5), radius: 4, x: 0, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .padding()
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            noteHeight = geo.size.height
                                            lastNoteHeight = noteHeight
                                        }
                                        .onChange(of: geo.size.height) { newHeight, oldHeight in
                                            lastNoteHeight = noteHeight
                                            noteHeight = newHeight
                                            
                                            let diff = noteHeight - lastNoteHeight
                                            if diff > 0 {
                                                withAnimation(.easeInOut) {
                                                    scrollProxy.scrollTo("NOTE_FIELD", anchor: .bottom)
                                                }
                                            }
                                        }
                                }
                            )
                            .onChange(of: note) { newValue, oldValue in
                                DispatchQueue.main.async {
                                    viewModel.countdown.note = newValue
                                    viewModel.saveChanges(context: context)
                                }
                            }
                    }
                    if showDuplicateMessage { duplicateMessage }
                    if showArchivedMessage { archivedMessage }
                }
                .keyboardAvoiding(50)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                
                Spacer()
                buttons
            }
            .background {
                if let baseColor = Color(hex: viewModel.countdown.colorHex ?? "#FBC024") {
                    LinearGradient(
                        colors: baseColor.opacity(0.5).gradientPair(),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
            }
            .fullScreenCover(isPresented: $showEditView, content: {
                NewCountdown(countdown: viewModel.countdown)
            })
            .sheet(isPresented: $showPaywall) {
                PaywallGoPremium(onClose: {
                    dismiss()
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
            }
            .navigationBarBackButtonHidden(true)
            .hideKeyboardOnTap()
        }
    }
}

#Preview {
    DetailView(
        countdown: .init(
            id: UUID(),
            name: "Birthday Party",
            icon: "🎂",
            date: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
            time: Date(),
            colorHex: "#FBC024",
            remindWhenFinished: true,
            remindDayBefore: false,
            remindWeekBefore: false,
            organizer: "Misha",
            tags: ["🎂 Birthdays", "🎉 Celebrations"],
            selectedUnits: ["Hours", "Minutes", "Seconds"]
        )
    )
    .environmentObject(StoreManager.init())
}

//MARK: EXTENSION
extension DetailView {
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
    
    private var title: some View {
        HStack(spacing: 16) {
            if let icon = viewModel.countdown.icon, !icon.isEmpty {
                let isFinished = viewModel.countdown.date <= Date()
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: viewModel.countdown.colorHex ?? "#FBC024")?.opacity(0.2)
                          ?? .expansesOrange.opacity(0.2))
                    .frame(width: 90, height: 90)
                    .overlay {
                        if isFinished {
                            Image(.checkmarkIcon)
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 44, height: 44)
                                .foregroundColor(Color.primary)
                        } else {
                            Text(icon)
                                .font(.system(size: 45))
                        }
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.countdown.name ?? "Countdownd")
                    .font(.system(size: 56, weight: .semibold, design: .default))
                    .lineSpacing(0)
                if !viewModel.countdown.allDay  {
                    Text(viewModel.formattedDate + ", " + viewModel.formattedTime)
                        .font(.system(size: 26, weight: .light, design: .default))
                } else {
                    Text(viewModel.formattedDate)
                        .font(.system(size: 30, weight: .light, design: .default))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var tags: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: -10),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            ForEach(viewModel.countdown.selectedTags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(6)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    )
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
    
    private var duplicateMessage: some View {
        HStack(spacing: 8) {
            Image(.checkmarkIcon)
                .resizable()
                .frame(width: 18, height: 18)
            Text("Countdown successfully duplicated!".localized)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.black.opacity(0.8)
        )
        .foregroundColor(.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut) {
                    showDuplicateMessage = false
                }
            }
        }
    }
    
    private var archivedMessage: some View {
        HStack(spacing: 8) {
            Image(.checkmarkIcon)
                .resizable()
                .frame(width: 18, height: 18)
            Text("Countdown successfully archived!".localized)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.black.opacity(0.8)
        )
        .foregroundColor(.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut) {
                    showArchivedMessage = false
                }
            }
        }
    }
    
    private var buttons: some View {
        HStack(spacing: 50) {
            //      ShareLink(
            //        item: viewModel.countdown.shareText
            //      ) {
            //        Circle()
            //          .frame(width: 48, height: 48)
            //          .foregroundStyle(Color.white)
            //          .overlay {
            //            Image("ShareIcon")
            //              .resizable()
            //              .frame(width: 31, height: 31)
            //              .scaledToFit()
            //          }
            //      }
            Button {
                showEditView.toggle()
            } label: {
                Circle()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color.white)
                    .overlay {
                        Image("EditIcon")
                            .resizable()
                            .frame(width: 29, height: 29)
                            .scaledToFit()
                    }
            }
            
            Button {
                showMoreDialog.toggle()
            } label: {
                Circle()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color.white)
                    .overlay {
                        Image("MoreIcon")
                            .resizable()
                            .frame(width: 38, height: 10)
                            .scaledToFit()
                    }
            }
            .popover(isPresented: $showMoreDialog, arrowEdge: .bottom) {
                HStack(spacing: 0) {
                    PopoverButton(
                        title: "Add Note".localized,
                        systemImage: "square.and.pencil",
                        tint: .expansesBlue
                    ) {
                        withAnimation(.smooth) {
                            showNote.toggle()
                        }
                    }
                    
                    PopoverButton(
                        title: "Archive".localized,
                        systemImage: "archivebox",
                        tint: .searchBarGray
                    ) {
                        viewModel.countdown.isArchived = true
                        withAnimation(.smooth) {
                            showArchivedMessage = true
                            showMoreDialog = false
                        }
                    }
                    
                    PopoverButton(
                        title: "Duplicate".localized,
                        systemImage: "doc.on.doc",
                        tint: .expansesOrange
                    ) {
                        let allCountdowns = viewModel.fetchAllCountdowns(context: context)
                        
                        if !store.premiumUnlocked && allCountdowns.count >= 5 {
                            showPaywall = true
                            showMoreDialog = false
                        } else {
                            viewModel.duplicateCountdown(context: context) {
                                withAnimation(.spring()) {
                                    showDuplicateMessage = true
                                    showMoreDialog = false
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.spring()) {
                                    showDuplicateMessage = false
                                }
                            }
                        }
                    }
                    
                    PopoverButton(
                        title: "Delete".localized,
                        systemImage: "trash",
                        tint: .expansesRed
                    ) {
                        showDeleteAlert.toggle()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .presentationCompactAdaptation(.popover)
            }
            .alert("Delete Countdown".localized, isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteCountdown(context: context)
                    dismiss.callAsFunction()
                }
                Button("Cancel".localized, role: .cancel) { }
            } message: {
                Text("Are you sure you want to permanently delete this countdown?".localized)
            }
        }
        .padding(.bottom, 40)
    }
}
