//
//  OrientationLockedView.swift
//  Mycountdown
//
//  Created by Danil Ovcharenko on 31.10.2025.
//

import SwiftUI

struct OrientationLockedView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        AppDelegate.orientationLock = .portrait
    }
    
    var body: some View {
        content
            .onAppear {
                AppDelegate.orientationLock = .portrait
            }
            .onDisappear {
                AppDelegate.orientationLock = .all
            }
    }
}
