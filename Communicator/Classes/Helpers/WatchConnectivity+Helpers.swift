//
//  WatchConnectivity+Helpers.swift
//  Pods
//
//  Created by Kane Cheshire on 20/07/2017.
//
//

import WatchConnectivity

extension Communicator.State {
    
    init(session: WCSessionActivationState) {
        switch session {
        case .notActivated: self = .notActivated
        case .inactive: self = .inactive
        case .activated: self = .activated
        @unknown default: self = .inactive
        }
    }
    
}

public extension Reachability {
    
    init(session: WCSession) {
        guard session.activationState == .activated else {
            self = .notReachable
            return
        }
        if session.isReachable {
            self = .immediatelyReachable
        } else {
            self = .backgroundOnly
        }
    }
    
}

#if os(iOS)

extension WatchState {
    
    init(session: WCSession) {
        if session.isPaired {
            self = .paired(.init(session: session))
        } else {
            self = .notPaired
        }
    }
    
}

extension WatchState.AppState {
    
    init(session: WCSession) {
        if session.isWatchAppInstalled {
            self = .installed(.init(session: session), session.watchDirectoryURL)
        } else {
            self = .notInstalled
        }
    }
    
}

extension WatchState.AppState.ComplicationState {
    
    init(session: WCSession) {
        if session.isComplicationEnabled {
            self = .enabled(numberOfUpdatesAvailableToday: session.remainingComplicationUserInfoTransfers)
        } else {
            self = .notEnabled
        }
    }
    
}

#endif
