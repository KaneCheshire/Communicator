//
//  ComplicationInfo.swift
//  Communicator
//
//  Created by Kane Cheshire on 20/07/2017.
//
//

import Foundation

/// Represents information to update complications in watchOS apps.
public struct ComplicationInfo {

    public typealias Completion = (Result<Int, Error>) -> Void
    
    /// The content of the ComplicationInfo as a JSON dictionary.
    public let content: Content
    
    /// Creates a new ComplicationInfo configured with some content.
    /// The content must be a JSON dictionary containing primitive plist types
    /// such as Strings, Ints, Data etc.
    ///
    /// - Parameter content: The content of the ComplicationInfo as a JSON dictionary.
    public init(content: Content) {
        self.content = content
    }
    
}
