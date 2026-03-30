//
//  PaywallGoPremium.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 13.01.2026.
//

import SwiftUI
import RevenueCat

struct PaywallGoPremium: View {
    
    @State private var selectedPlan: Plan = .year
    @EnvironmentObject var store: StoreManager
    @State private var showMoreOptions = false
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var bottomY: CGFloat = 0
    
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            BlurCustomBackground()
            
            VStack(spacing: 0) {
                
                ScrollView(.vertical, showsIndicators: false) {
                    contentBody
                }
                .scrollIndicators(.hidden)
                .mask(
                    VStack(spacing: 0) {
                        
                        Color.white
                        
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 30)
                    }
                )
                bottonBar
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            store.loadOfferings()
            
            Task {
                do {
                    _ = try await Purchases.shared.syncPurchases()
                } catch {
                    print("Sunc purchases failed:", error)
                }
            }
            
        }
    }
}

//MARK: - Layout Sections

extension PaywallGoPremium {
    
    private var contentBody: some View {
        VStack(spacing: 15) {
            
            VStack {
                header
                heroSection
            }
            
            plansSection
                .padding(.top, 15)
            
            ratingSection
            quoteSection
            featuresSection
            
        }
        .padding(.bottom, 140)
    }
    
    private var bottonBar: some View {
        VStack(spacing: 4) {
            
            GradientButton(title: selectedPlan == .year ? "FREE 3-day trial period".localized : "ADD UNLIMITED EVENTS".localized,
                           subtitle: selectedPlan == .year ? "✓️ No payment due now".localized : nil
            ) {
                Task {
                    do {
                        switch selectedPlan {
                        case .week:
                            if let package = store.weeklyPackage {
                                try await store.purchase(package: package)
                            }
                        case .year:
                            if let package = store.yearlyPackage {
                                try await store.purchase(package: package)
                            }
                            
                        case .lifetime:
                            if let package = store.lifetimePackage {
                                try await store.purchase(package: package)
                            }
                        }
                    } catch {
                        print("Purchase failed: ", error)
                    }
                }
            }
            .disabled(store.purchaseInProgress)
            .opacity(store.purchaseInProgress ? 0.6 : 1)
            
            Text(selectedPlan == .lifetime ? "Pay once, unlimited access forever".localized : "Cancel anytime.\nRefund guaranteed.".localized)
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            
            PaywallFooter()
        }
        .padding(.horizontal, 24)
        .padding(.top, 0)
        .padding(.bottom, 16)
    }
}

//MARK: - Sections

extension PaywallGoPremium {
    
    private var featuresSection: some View {
        VStack(spacing: 12) {
            ForEach(PaywallGoPremiumData.features) { feature in
                FeatureCard(feature: feature)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var quoteSection: some View {
        Text("“It feels playful, but I’m actually being productive”".localized)
            .font(.custom("Pacifico", size: 25))
            .foregroundStyle(.noteGray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }
    
    private var ratingSection: some View {
        AppStoreRatingSection(rating: 4.6, switchColorMode: false)
    }
    
    private var plansSection: some View {
        VStack {
            VStack(spacing: 16) {
                
                if let yeraly = store.yearlyPackage {
                    
                    PaywallPlanRow(
                        title: "1 Year".localized,
                        subtitle: String(format: "per year".localized, yeraly.localizedPrice),
                        price: "≈ " + yeraly.storeProduct.yearEquivalent() , duration: "/ month".localized,
                        isSelected: selectedPlan == .year,
                        hasTrial: true
                    ) {
                        withAnimation(.easeOut(duration: 0.45)) {
                            selectedPlan = .year
                        }
                    }
                }
                
                if let weekly = store.weeklyPackage {
                    PaywallPlanRow(
                        title: "1 Week".localized,
                        subtitle: String(format: " paid weekly".localized, weekly.localizedPrice),
                        price: weekly.localizedPrice , duration: "/ week".localized,
                        isSelected: selectedPlan == .week,
                        hasTrial: false
                    ) {
                        withAnimation(.easeOut(duration: 0.45)) {
                            selectedPlan = .week
                        }
                    }
                }
                
                if showMoreOptions {
                    if let lifetime = store.lifetimePackage {
                        PaywallPlanRow(
                            title: "Lifetime".localized,
                            subtitle: "One-time payment".localized,
                            price: lifetime.localizedPrice, duration: "Paid Once".localized,
                            isSelected: selectedPlan == .lifetime,
                            hasTrial: false
                        ) {
                            withAnimation(.easeOut(duration: 0.45)) {
                                selectedPlan = .lifetime
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            
            if !showMoreOptions {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        showMoreOptions = true
                    }
                } label: {
                    Text("v see options".localized)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            Image(.myCountdownLaunch)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
            Group {
                Text("Becomes ".localized)
                    .foregroundStyle(.black)
                + Text("7x more efficient".localized)
                    .foregroundStyle(.proYellow)
                + Text("\nand never forgets an event".localized)
                    .foregroundStyle(.black)
            }
            .multilineTextAlignment(.center)
            .font(.custom("PTSans-Bold", size: 26))
        }
        .padding(.horizontal, 24)
    }
    
    private var header: some View {
        HStack {
            Spacer()
            
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 36, height: 36)
                
            }
        }
        .padding(.horizontal)
    }
}

//MARK: - Footer

extension PaywallGoPremium {
    
    struct PaywallFooter: View {
        
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.openURL) private var openURL
        @EnvironmentObject private var store: StoreManager
        
        var body: some View {
            HStack(spacing: 0) {
                
                footerButton("Confidentiality".localized) {
                    openURL(URL(string: "https://docs.google.com/document/d/19lYjZXIi3-4L_tYl-t4nBFoAFLG1gdBkEnARcRnQWfQ/edit?usp=sharing")!)
                }
                
                footerButton("Terms".localized) {
                    openURL(URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula")!)
                }
                
                footerButton("Restore".localized) {
                    restorePurchases()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            
        }
        
        private func footerButton(_ title: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            
        }
        
        private func restorePurchases() {
            Task {
                await store.restorePurchases()
            }
        }
    }
}

//MARK: - Future Card

extension PaywallGoPremium {
    
    struct FeatureCard: View {
        
        @Environment(\.colorScheme) private var colorScheme
        let feature: Feature
        
        var body: some View {
            HStack(spacing: 14) {
                
                iconView
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    
                    Text(feature.subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(colorScheme == .dark ? .gray.opacity(0.7) : .white.opacity(0.7))
            )
        }
        
        @ViewBuilder
        private var iconView: some View {
            switch feature.icon {
            case .image(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                
            case .emoji(let emoji):
                Text(emoji)
                    .font(.system(size: 28))
            }
        }
    }
}

#Preview {
    PaywallGoPremium(onClose: {})
        .environmentObject(StoreManager())
}
