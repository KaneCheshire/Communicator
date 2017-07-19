//
//  Blob.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation

/// Represents some data to send between devices. A Blob is similar to a Message
/// except that it's content is just pure data. Use a Blob to send larger data
/// between devices.
public struct Blob {
    
    public typealias CompletionHandler = ((Error?) -> Void)
    
    /// Represents an error that may occur.
    ///
    /// - missingIdentifier: Indicates that an identifier is missing.
    /// - missingContent: Indicates that the content is missing.
    enum ErrorType: Error {
        case missingIdentifier
        case missingContent
    }
    
    // MARK: - Properties -
    // MARK: Public
    
    /// The Blob's identifer, defined by your app.
    public let identifier: String
    /// The content of the Blob as pure Data.
    public let content: Data
    /// An optional completion handler to execute when the Blob has transferred.
    public let completionHandler: CompletionHandler?
    
    // MARK: - Initialisers -
    // MARK: Public
    
    /// Creates a new instance configured with an identifier, some data as content an
    /// optionally a completion handler to execute when the Blob has transferred.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the Blob. Your app is responsible
    ///                 for creating and knowing these identifiers.
    ///   - content: The content of the Blob as Data.
    ///   - completionHandler: An optional completion handler to execute when the blob has transferred.
    public init(identifier: String, content: Data, completionHandler: CompletionHandler? = nil) {
        self.identifier = identifier
        self.content = content
        self.completionHandler = completionHandler
    }
    
    // MARK: Internal
    
    init(jsonDictionary: JSONDictionary) throws {
        guard let identifier = jsonDictionary["identifier"] as? String else {
            throw ErrorType.missingIdentifier
        }
        guard let content = jsonDictionary["content"] as? Data else {
            throw ErrorType.missingContent
        }
        self.init(identifier: identifier, content: content)
    }
    
    // MARK: - Functions -
    // MARK: Internal
    
    func jsonRepresentation() -> JSONDictionary {
        return ["identifier" : identifier,
                "content" : content]
    }
    
    func dataRepresentation() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject:jsonRepresentation())
    }
    
}
