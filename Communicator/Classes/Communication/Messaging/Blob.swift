//
//  Blob.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation

/// A `Blob` is similar to a `GuaranteedMessage`,
/// except that it's content is just pure data.
///
/// Use a `Blob` to send larger data between devices.
///
/// You can observe received `Blob`s by calling `Blob.observe {}`
public struct Blob {
    
    public typealias Completion = ((Result<Void, Error>) -> Void)
    
    /// The `Blob`'s identifer, defined by your app.
    public let identifier: String
    /// The content of the `Blob` as pure `Data`.
    public let content: Data
    
    /// Creates a new instance configured with an `identifier`, some data as `content`.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the `Blob`. Your app is responsible
    ///                 for creating and knowing these identifiers.
    ///   - content: The content of the `Blob` as `Data`.
    public init(identifier: String, content: Data) {
        self.identifier = identifier
        self.content = content
    }
    
}
