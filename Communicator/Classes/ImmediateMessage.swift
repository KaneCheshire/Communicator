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
    
    public typealias ReplyHandler = ([String : Any]) -> Void
    public typealias ErrorHandler = (Error) -> Void
    
    /// Represents an error that may occur.
    ///
    /// - missingIdentifier: Indicates that an identifier is missing.
    /// - missingContent: Indicates that the content is missing.
    enum ErrorType: Error {
        case missingIdentifier
        case missingContent
    }
    
    // MARK: - Properties -
    // MAR
    
    /// The Message's identifer, defined by your app.
    public let identifier: String
    /// The content of the Message in a JSON dictionary format.
    public let content: JSONDictionary
    /// An optional reply handler to execute in response to a message.
    public let replyHandler: ReplyHandler?
    /// An optional error handler to execute in the event of an error.
    public let errorHandler: ErrorHandler?
    
    // MARK: - Initialisers -
    // MARK: Public
    
    /// Creates a new message instance, configured with an identifier,
    /// some content in the form of a JSON dictionary with plist values,
    /// an optional reply handler and an optional error handler.
    ///
    /// On the sender's side, the reply handler will be called by the system when
    /// the receiver executes the reply handler on its side.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the Message. Your app is responsible
    ///                 for creating and knowing these identifiers.
    ///   - content: The content of the Message. Content must be in a JSON dictionary
    ///              format with only plist values. i.e, String, Int, Data etc.
    ///   - replyHandler: An optional reply handler.
    ///   - errorHandler: An optional error handler.
    public init(identifier: String, content: JSONDictionary, replyHandler: ReplyHandler? = nil, errorHandler: ErrorHandler? = nil) {
        self.identifier = identifier
        self.content = content
        self.replyHandler = replyHandler
        self.errorHandler = errorHandler
    }
    
    // MARK: Internal
    
    init(jsonDictionary: JSONDictionary, replyHandler: ReplyHandler? = nil) throws {
        guard let identifier = jsonDictionary["identifier"] as? String else {
            throw ErrorType.missingIdentifier
        }
        guard let content = jsonDictionary["content"] as? JSONDictionary else {
            throw ErrorType.missingContent
        }
        self.init(identifier: identifier, content: content, replyHandler: replyHandler, errorHandler: nil)
    }
    
    // MARK: - Functions -
    // MARK: Internal
    
    func jsonRepresentation() -> JSONDictionary {
        return ["identifier" : identifier,
                "content" : content]
    }
    
}

