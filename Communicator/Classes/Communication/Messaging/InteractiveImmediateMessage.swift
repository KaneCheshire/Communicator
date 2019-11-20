//
//  InteractiveImmediateMessage.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

/// An InteractiveImmediateMessage is similar to an ImmediateMessage but it
/// supports the receiver calling a reply handler to interact with the message.
///
/// When the receiver calls the reply handler, it is executed automatically on the sender's side by the system.
public struct InteractiveImmediateMessage {
    
    public typealias Reply = (ImmediateMessage) -> Void
    public typealias ErrorHandler = (Error) -> Void
    
    /// The  identifer, defined by your app.
    public let identifier: String
    /// The content of the Message in a JSON dictionary format.
    public let content: Content
    /// The reply handler that the receiver can call for it to automatically be executed on the sender's side by the system.
    public let reply: Reply
    
    /// Creates a new instance configured with an identifier, some content and a reply handler for the receiving side to call.
    /// - Parameters:
    ///   - identifier: The identifier, defined by you.
    ///   - content: The content. This must be in a JSON dictionary format, so strings, numbers, data etc.
    ///   - reply: The reply handler for the receiver to call with a reply message.
    public init(identifier: String, content: Content = [:], reply: @escaping Reply) {
        self.identifier = identifier
        self.content = content
        self.reply = reply
    }
    
}

extension InteractiveImmediateMessage {
    
    init?(content: Content, reply: @escaping Reply) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Content else { return nil }
        self.init(identifier: identifier, content: content, reply: reply)
    }
    
}

extension InteractiveImmediateMessage: ContentPackagable {}
