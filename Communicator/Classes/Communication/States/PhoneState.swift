//
//  PhoneState.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 21/11/2019.
//

import Foundation


#if os(watchOS)

/// Represents the current state of the user's iPhone paired with this watch.
/// You can observe changes to `PhoneState` by calling `PhoneState.observe {}
///
/// Currently, it's not possible to have an Apple Watch without it being `paired`, so these cases
/// exist purely for forwards compatibility without breaking APIs.
public enum PhoneState {
    
    case paired(AppState)
    case notPaired
    
    /// Represents the state of the iOS app on the paired iPhone.
    /// Since watchOS 6, it's possible to install watch apps without the iPhone app being installed.
    /// On anything lower than watchOS 6, this will always be `installed`.
    public enum AppState {
        case installed
        case notInstalled
    }
    
}

#endif
