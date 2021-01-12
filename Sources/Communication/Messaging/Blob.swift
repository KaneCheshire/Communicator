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
    /// Optional metadata associated with this `Blob`.
    public let metadata: Content?
    
    /// Creates a new instance configured with an `identifier`, some data as `content`.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the `Blob`. Your app is responsible
    ///                 for creating and knowing these identifiers.
    ///   - content: The content of the `Blob` as `Data`.
    ///   - metadata: Optional metadata to transfer along with the raw data.
    public init(identifier: String, content: Data, metadata: Content? = nil) {
        self.identifier = identifier
        self.content = content
        self.metadata = metadata
    }
    
}
