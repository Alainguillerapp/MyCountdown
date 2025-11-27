//
//  EKEvent.swift
//  Mycountdown
//
//  Created by Michael on 11/19/25.
//

import Foundation
import EventKit

extension EKEvent {
  var uniqueID: String {
    "\(eventIdentifier ?? UUID().uuidString)_\(startDate.timeIntervalSince1970)"
  }
}
