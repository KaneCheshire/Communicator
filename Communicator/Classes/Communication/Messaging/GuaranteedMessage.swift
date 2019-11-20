//
//  GuaranteedMessage.swift
//  Pods
//
//  Created by Kane Cheshire on 13/03/2018.
//

import Foundation

/// Represents a message that can be sent between devices but might
/// not be sent immediately.
///
/// As guaranteed messages might be received after the sending device's
/// session is unavailable, reply handlers are not supported.
/// To use reply handlers, see `InteractiveImmediateMessage`.
///
/// Do not use a Message to send large amounts of data because the
/// system will reject it, instead, use a Blob.
public struct GuaranteedMessage {
    
    public typealias Completion = (Result<Void, Error>) -> Void
    
    /// The Message's identifer, defined by your app.
    public let identifier: String
    /// The content of the Message in a JSON dictionary format.
    public let content: Content
    
    /// Creates a new message instance, configured with an identifier,
    /// some content in the form of a JSON dictionary with plist values.
    ///
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

extension GuaranteedMessage {
    
    init?(content: Content) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Content else { return nil }
        self.init(identifier: identifier, content: content)
    }
    
}

extension GuaranteedMessage: ContentPackagable {}
