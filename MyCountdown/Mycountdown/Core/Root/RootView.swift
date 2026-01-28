//
//  RootView.swift
//  Mycountdown
//
//  Created by GetApple on 30.12.2025.
//

import SwiftUI
import SwiftData

struct RootView: View {
    
    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: StoreManager
    @State private var showPaywall = false
    
    
    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainView()
            } else {
                OnboardingView(
                    onFinish: {
                        hasSeenOnboarding = true
                        showPaywall = true
                        
                    }
                )
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallGoPremium(onClose: { showPaywall = false })
        }
    }
}

#Preview {
    RootView()
}
