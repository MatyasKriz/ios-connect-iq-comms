//
//  MessageView.swift
//
//  Created by Matyáš Kříž on 01/03/2020.
//

import SwiftUI
import Combine

struct MessageView: View {
    @State private var message = ""
    private let messagePublisher: AnyPublisher<String, Never>
    private let callback: () -> Void

    init(messagePublisher: AnyPublisher<String, Never>, callback: @escaping () -> Void) {
        self.messagePublisher = messagePublisher
        self.callback = callback
    }

    var body: some View {
        Text(message.isEmpty ? "No message from the spirits." : "The spirits say:\n\(message)")
            .multilineTextAlignment(.center)
            .onTapGesture {
                self.callback()
            }
            .onReceive(messagePublisher) { self.message = $0 }
    }
}
