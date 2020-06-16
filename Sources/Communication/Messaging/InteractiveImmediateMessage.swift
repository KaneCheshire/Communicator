//
//  InteractiveImmediateMessage.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

/// An `InteractiveImmediateMessage` is very similar to an `ImmediateMessage` but it
/// supports the receiver calling a `reply` handler to interact with the message.
///
/// Immedate messages are _not_ guaranteed, and will fail if either of the sender or
/// receiver session becomes unavailable while sending.
///
/// When the receiver calls the `reply` handler, it is executed automatically on the sender's side by the system.
///
/// If you don't want an immediate reply, just use a regular `ImmediateMessage`.
///
/// You can observe received `InteractiveImmediateMessage`s by calling `InteractiveImmediateMessage.observe {}`
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
