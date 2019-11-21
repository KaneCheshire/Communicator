//
//  GuaranteedMessage.swift
//  Pods
//
//  Created by Kane Cheshire on 13/03/2018.
//

import Foundation

/// Represents a message that can be sent between devices but might
/// not be sent immediately, depending on the current reachability.
///
/// As guaranteed messages might be received after the sending device's
/// session is unavailable, reply handlers are not supported.
///
/// To use reply handlers, use an `InteractiveImmediateMessage`.
///
/// Do not use a `GuaranteedMessage` to send large amounts of data because the
/// system will reject it, instead, use a `Blob`.
///
/// You can observe received `GuaranteedMEssage`s by calling `GuaranteedMessage.observe {}`
public struct GuaranteedMessage {
    
    public typealias Completion = (Result<Void, Error>) -> Void
    
    /// The `GuaranteedMessage`'s identifer, defined by your app.
    public let identifier: String
    /// The content of the `GuaranteedMessage` in a JSON dictionary format.
    public let content: Content
    
    /// Creates a new `GuaranteedMessage`, configured with an `identifier`,
    /// some `content` in the form of a JSON dictionary with plist values.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the `GuaranteedMessage`. Your app is responsible
    ///                 for creating and knowing these identifiers.
    ///   - content: The content of the `GuaranteedMessage`. Content must be in a JSON dictionary
    ///              format with only plist values. i.e, String, Int, Data etc.
    public init(identifier: String, content: Content = [:]) {
        self.identifier = identifier
        self.content = content
    }
    
}
