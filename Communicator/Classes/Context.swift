//
//  Context.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation

/// Represents a lightweight object that both devices know how to use.
/// A good use for a Context is to sync user settings.
public struct Context {
    
    // MARK: - Properties -
    // MARK: Public
    
    /// The Context's content, in a JSON dictionary format.
    public let content: JSONDictionary
    
    // MARK: - Initialisers -
    // MARK: Public
    
    /// Creates a new Context instance, configured with content in the
    /// form of a JSON dictionary. The dictionary's contents must
    /// be plist values or the system will reject it.
    ///
    /// - Parameter content: The content of the Context, in JSON dictionary format.
    ///                      The JSON dictionary must contain only plist values,
    ///                      I.e. Strings, Ints and Data etc.
    public init(content: JSONDictionary) {
        self.content = content
    }
    
}
