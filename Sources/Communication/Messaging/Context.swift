//
//  Context.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation

/// Represents a very lightweight object that both devices know how to use.
/// A good use for a `Context` is to sync user settings.
///
/// When you send or a receive a `Context`, the system automatically
/// discards the previous one.
///
/// You can query the latest sent or received
/// context at any time using `Communicator.shared.mostRecentlySentContext`
/// and `Communicator.shared.mostRecentlyReceivedContext`
///
/// You can observe received `Context`s by calling `Context.observe {}`
public struct Context {
    
    /// The `Context`'s content, in a JSON dictionary format.
    public let content: Content
    
    /// Creates a new `Context`, configured with `content` in the
    /// form of a JSON dictionary. The dictionary's contents must
    /// be plist values or the system will reject it.
    ///
    /// - Parameter content: The content of the `Context`, in JSON dictionary format.
    ///                      The JSON dictionary must contain only plist values,
    ///                      I.e. Strings, Ints and Data etc.
    public init(content: Content) {
        self.content = content
    }
    
}
