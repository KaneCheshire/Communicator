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
    
    public typealias Completion = ((Result<Void, Error>) -> Void)
    
    /// The Blob's identifer, defined by your app.
    public let identifier: String
    /// The content of the Blob as pure Data.
    public let content: Data
    
    /// Creates a new instance configured with an identifier, some data as content an
    /// optionally a completion handler to execute when the Blob has transferred.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the Blob. Your app is responsible
    ///                 for creating and knowing these identifiers.
    ///   - content: The content of the Blob as Data.
    public init(identifier: String, content: Data) {
        self.identifier = identifier
        self.content = content
    }
    
}

extension Blob {
    
    init?(content: Content) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Data else { return nil }
        self.init(identifier: identifier, content: content)
    }
    
    
    func dataRepresentation() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: ["identifier" : identifier,
                                                             "content" : content])
    }
    
}
