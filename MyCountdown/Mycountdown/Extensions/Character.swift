//
//  Character.swift
//  Mycountdown
//
//  Created by Michael on 11/10/25.
//

import Foundation

extension Character {
    var isEmoji: Bool {
        unicodeScalars.contains { $0.properties.isEmoji }
    }
}
