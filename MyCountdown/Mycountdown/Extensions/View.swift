//
//  View.swift
//  Mycountdown
//
//  Created by Michael on 11/10/25.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
    
    func keyboardAvoiding(_ inset: CGFloat) -> some View {
        modifier(KeyboardAvoiding(inset: inset))
    }
    
    func textOutline(
        color: Color = .black,
        width: CGFloat = 1
    ) -> some View {
        self
            .shadow(color: color, radius: width, x: 0, y: 0)
            .shadow(color: color, radius: width, x: width, y: 0)
            .shadow(color: color, radius: width, x: -width, y: 0)
            .shadow(color: color, radius: width, x: 0, y: width)
            .shadow(color: color, radius: width, x: 0, y: -width)
    }
}

