//
//  WatchState.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation
import WatchConnectivity

#if os(iOS)

/// Represents the current state of the user's Apple Watch (or multiple Apple Watches if they have more than one paired).
/// i.e. paired or not paired.
///
/// You can observe changes to `WatchState`s by calling `WatchState.observe {}`
public enum WatchState {
    
    /// The user has a paired Apple Watch. This case also provides the `AppState`, which will tell you if your watch app and any complications are installed.
    case paired(AppState)
    /// The user has no paired Apple Watch.
    case notPaired
    
    /// Represents the state of your watch app on the user's watch.
    /// i.e. either installed or not installed.
    public enum AppState {
        
        /// Your watch app is installed on the active watch. This case also provides the complication state and a watch specific URL.
        /// The `WatchSpecificURL` may be nil if the session state is inactive.
        case installed(ComplicationState, WatchSpecificLocalURL?)
        /// Your watch app is not installed on the active watch.
        case notInstalled
        
        /// Represents the state of your complications on the users current watch face.
        /// i.e.  enabled or not enabled. This can change as the user changes watch faces.
        public enum ComplicationState {
            
            /// The user has enabled one or more of your app's complications on the currently active watch face.
            /// This case also provides the number of `ComplicationInfo` transfers available, which can be up to 50 a day.
            case enabled(numberOfUpdatesAvailableToday: Int)
            /// The user has not enabled any of your app's complications on the currently active watch face.
            case notEnabled
            
        }
        
        /// Represents a URL specific to the currently active paired watch. If the user switches watches,
        /// this URL will change.
        /// If the user deletes your app from their watch or unpairs their watch, the contents of this URL
        /// are automatically deleted by the system.
        /// Use this URL to store watch-specific info that you need to identify between different paired watches,
        /// for example you could store a token to say whether you've sent inital content for a paired watch,
        /// so you know when to send initial content for any new paired watches.
        public typealias WatchSpecificLocalURL = URL
        
    }
    
}

public extension WatchState {
    
    var appState: AppState {
        switch self{
            case .notPaired: return .notInstalled
            case .paired(let appState): return appState
        }
    }
    
    var complicationState: AppState.ComplicationState {
        switch appState {
            case .notInstalled: return .notEnabled
            case .installed(let compState, _): return compState
        }
    }
    
    /// Convenience property for obtaining the current number of transfers available
    var numberOfComplicationUpdatesAvailableToday: Int {
        switch complicationState {
            case .notEnabled: return 0
            case .enabled(let numberAvailable): return numberAvailable
        }
    }
    
}

#endif
