//
//  ComplicationInfo.swift
//  Communicator
//
//  Created by Kane Cheshire on 20/07/2017.
//
//

import Foundation

/// Represents information to update active complications in your watchOS app.
/// `ComplicationInfo` does not take an identifier since it's not really a message.
///
/// Transferring a `ComplicationInfo` will take up your watch app in the background,
/// so long as you haven't met the per-day limit for transfers and at least one complication
/// is added on the user's active watch face.
///
/// You can query the number of transfers remaining at any time by querying the latest `WatchState.`
///
/// You can observe received `ComplicationInfo`s by calling `ComplicationInfo.observe {}`
public struct ComplicationInfo {

    public typealias Completion = (Result<Int, Error>) -> Void
    
    /// The content of the `ComplicationInfo` as a JSON dictionary.
    public let content: Content
    
    /// Creates a new `ComplicationInfo` configured with some content.
    /// The content must be a JSON dictionary containing primitive plist types
    /// such as Strings, Ints, Data etc.
    ///
    /// - Parameter content: The content of the `ComplicationInfo` as a JSON dictionary.
    public init(content: Content) {
        self.content = content
    }
    
}
