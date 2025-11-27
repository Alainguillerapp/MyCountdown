//
//  MailComposerViewController.swift
//  Mycountdown
//
//  Created by Michael on 11/13/25.
//

import Foundation
import MessageUI
import SwiftUI

struct MailComposerViewController: UIViewControllerRepresentable {
  
  @Environment(\.dismiss) var dismiss
  var recipients: [String]
  var subject: String
  var messageBody: String
  
  func makeUIViewController(context: Context) -> MFMailComposeViewController {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = context.coordinator
    mailComposer.setToRecipients(recipients)
    mailComposer.setSubject(subject)
    mailComposer.setMessageBody(messageBody, isHTML: false)
    return mailComposer
  }
  
  func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    var parent: MailComposerViewController
    
    init(_ parent: MailComposerViewController) {
      self.parent = parent
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      parent.dismiss()
    }
  }
}
