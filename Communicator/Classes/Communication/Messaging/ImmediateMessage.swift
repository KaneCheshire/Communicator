//
//  ImmediateMessage.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation

/// Represents a message that can be sent between devices being received
/// (almost) immediately, while both device's sessions are available.
///
/// Immedate messages support configuring with a reply handler that gets called
/// on the sender's side when it is called by the receiver.
///
/// Immedate messages are not guaranteed, and will fail if either of the sender or
/// receiver session becomes unavailable while sending/replying.
///
/// Do not use a Message to send large amounts of data because the
/// system will reject it, instead, use a Blob.
public struct ImmediateMessage {
    
    public typealias ErrorHandler = (Error) -> Void
    
    // MARK: - Properties -
    // MARK: Public
    
    /// The Message's identifer, defined by your app.
    public let identifier: String
    /// The content of the Message in a JSON dictionary format.
    public let content: Content
    
    // MARK: - Initialisers -
    // MARK: Public
    
    /// Creates a new message instance, configured with an identifier,
    /// some content in the form of a JSON dictionary with plist values.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the Message. Your app is responsible
    ///                 for creating and knowing these identifiers.
    ///   - content: The content of the Message. Content must be in a JSON dictionary
    ///              format with only plist values. i.e, String, Int, Data etc.
    public init(identifier: String, content: Content) {
        self.identifier = identifier
        self.content = content
    }
    
}

extension ImmediateMessage {
    
    init?(content: Content) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Content else { return nil }
        self.init(identifier: identifier, content: content)
    }
    
}

extension ImmediateMessage: ContentPackagable {}

