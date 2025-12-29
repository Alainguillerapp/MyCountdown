//
//  GoPremiumView.swift
//  Mycountdown
//
//  Created by Michael on 11/13/25.
//

import SwiftUI

struct GoPremiumView: View {
    
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StoreManager
    @State private var showMailError = false
    @State private var plsSendMailAlert = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            header
            widgetSection
            descriptionText
            
            Button {
                Task {
                    await store.buyPremium()
                }
            } label: {
                HStack {
                    Group {
                        Text("UNLOCK FOREVER FOR ".localized)
                            .font(.system(size: 16, weight: .medium, design: .default))
                        +
                        Text("2,99 USD".localized)
                            .font(.system(size: 18, weight: .heavy, design: .default))
                    }
                }
                .foregroundStyle(.white)
                .frame(height: 61)
                .frame(maxWidth: 350)
                .background(.orangePremium)
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .orangePremium.opacity(0.3), radius: 20, x: 0, y: 6)
                .padding(.horizontal)
            }
            
            Button {
                Task {
                    await store.restore()
                }
            } label: {
                Text("Restore purchases".localized)
                    .foregroundStyle(.premiumGray)
                    .font(.system(size: 16, weight: .medium))
            }
            
            Spacer()
            
            Button {
                plsSendMailAlert = true
//                sendEmail()
            } label: {
                Text("No subscriptions. No surprises.\nIf you have any questions, just tap here.".localized)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.premiumGray)
            }
        }
        .alert("Mail not avaible",
               isPresented: $showMailError) {
            Button("OK", role: .cancel) {}
        } message: {
        Text("Please configure a mail account on your device.")
        }
        .alert("Pleas send us an email to".localized,
               isPresented: $plsSendMailAlert) {
            Button("OK", role: .cancel) {}
        } message: {
        Text("alainguiller.app@gmail.com")
        }
    }
}

#Preview {
    GoPremiumView()
}

//MARK: EXTENSION
extension GoPremiumView {
    private func sendEmail() {
        let email = "alainguiller.app@gmail.com"
        let subject = "Support request"
        
        let urlString =
                "mailto:\(email)?subject=\(subject)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
        guard let url = URL(string: urlString ?? "") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            openURL(url)
        } else {
            showMailError = true
        }
    }
    
    private var header: some View {
        HStack {
            Image("Vector")
                .renderingMode(.template)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
                .onTapGesture {
                    dismiss.callAsFunction()
                }
            Spacer()
            Text("Go premium".localized)
                .font(.system(size: 24, weight: .semibold, design: .default))
            Spacer()
            Image("Vector")
                .opacity(0)
        }
        .padding(.horizontal)
        .padding()
    }
    
    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 25) {
                RoundedRectangle(cornerRadius: 25)
                    .frame(width: 150, height: 150)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.expansesGreen.opacity(0.7), .noteGray],
                            startPoint: .bottomLeading,
                            endPoint: .trailing
                        )
                    )
                    .blur(radius: 0.5)
                    .overlay {
                        VStack(spacing: 0) {
                            HStack {
                                Text("🎪")
                                    .font(.caption)
                                    .padding(7)
                                    .background(.expansesGreen)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .shadow(color: .white, radius: 0.1, x: 0, y: 0)
                                
                                Text("Summer Festival\n2025".localized)
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            Text("10")
                                .font(.system(size: 50, weight: .semibold))
                            Text("days left".localized)
                                .font(.system(size: 18, weight: .light))
                                .padding(.top, -10)
                            Text("Thu, 6 Nov 2025")
                                .font(.system(size: 10, weight: .light))
                                .padding(.top, 8)
                        }
                        .foregroundStyle(.white)
                    }
                
                RoundedRectangle(cornerRadius: 25)
                    .frame(width: 150, height: 150)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.expansesBlue.opacity(0.7), .noteGray],
                            startPoint: .bottomLeading,
                            endPoint: .trailing
                        )
                    )
                    .blur(radius: 0.5)
                    .overlay {
                        VStack(spacing: 0) {
                            HStack {
                                Text("📅")
                                    .font(.caption)
                                    .padding(7)
                                    .background(.expansesBlue)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .shadow(color: .white, radius: 0.1, x: 0, y: 0)
                                
                                Text("New Event".localized)
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            Text("19")
                                .font(.system(size: 50, weight: .semibold))
                            Text("days left".localized)
                                .font(.system(size: 18, weight: .light))
                                .padding(.top, -10)
                            Text("Fri, 26 Nov 2025".localized)
                                .font(.system(size: 10, weight: .light))
                                .padding(.top, 8)
                        }
                        .foregroundStyle(.white)
                    }
            }
            
            RoundedRectangle(cornerRadius: 25)
                .frame(width: 320, height: 150)
                .foregroundStyle(.noteGray.opacity(0.75))
                .blur(radius: 0.5)
                .overlay {
                    VStack(spacing: 6) {
                        HStack {
                            Text("🎵")
                                .font(.caption)
                                .padding(7)
                                .background(.expansesOrange)
                                .clipShape(.rect(cornerRadius: 10))
                                .shadow(color: .white, radius: 0.1, x: 0, y: 0)
                            
                            VStack(alignment: .leading) {
                                Text("Music Festival".localized)
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Fri, 26 Nov 2025".localized)
                                    .font(.system(size: 10, weight: .light))
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 0) {
                                Text("10")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("days left".localized)
                                    .font(.system(size: 10, weight: .light))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("🚀")
                                .font(.caption)
                                .padding(7)
                                .background(.expansesRed)
                                .clipShape(.rect(cornerRadius: 10))
                                .shadow(color: .white, radius: 0.1, x: 0, y: 0)
                            
                            VStack(alignment: .leading) {
                                Text("Music Festival".localized)
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Fri, 26 Nov 2025".localized)
                                    .font(.system(size: 10, weight: .light))
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 0) {
                                Text("7")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("days left".localized)
                                    .font(.system(size: 10, weight: .light))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("📅")
                                .font(.caption)
                                .padding(7)
                                .background(.expansesBlue)
                                .clipShape(.rect(cornerRadius: 10))
                                .shadow(color: .white, radius: 0.1, x: 0, y: 0)
                            
                            VStack(alignment: .leading) {
                                Text("Music Festival".localized)
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Fri, 26 Nov 2025")
                                    .font(.system(size: 10, weight: .light))
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 0) {
                                Text("60")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("days left".localized)
                                    .font(.system(size: 10, weight: .light))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                    }
                    .foregroundStyle(.white)
                }
        }
    }
    
    private var descriptionText: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(.lockIcon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.primary)
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                Text(" Unlock All Widgets forever".localized)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            
            HStack {
                Image(.starIcon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.primary)
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                Text(" Add unlimited events".localized)
            }
            
            HStack {
                Image(.checkCircleIcon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.primary)
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                Text(" Pay once, use it forever".localized)
            }
        }
        .font(.system(size: 20, weight: .regular))
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}


