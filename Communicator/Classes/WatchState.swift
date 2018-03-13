//
//  WatchState.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation

#if os(iOS)
    
/// Represent the current state of the user's Apple Watch.
public struct WatchState {
    
    /// Whether the user has a paired Apple Watch.
    public let isPaired: Bool
    
    /// Whether the user's Apple Watch has your app installed.
    public let isWatchAppInstalled: Bool
    
    /// Whether the user has enabled one or more of your complications.
    public let isComplicationEnabled: Bool
    
    /// The amount of complication updates you can make from your iOS app.
    /// On iOS versions before iOS 10 this will be -1.
    public let numberOfComplicationInfoTransfersAvailable: Int
    
    /// Represents a system-defined URL pointing to a directory on the
    /// user's iPhone which you can write items to specific to a
    /// particular watch. When the user switches watches, this URL will change,
    /// meaning you can store things specific to each individual watch separately.
    /// If the user deletes your app from one of their watches, this directory is
    /// deleted by the system automatically.
    public let watchSpecificDirectoryURL: URL?
    
}
    
#endif
