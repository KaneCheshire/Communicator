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
        #if os(iOS)
        guard session.isWatchAppInstalled else {
            self = .notReachable
            return
        }
        #endif
        #if os(watchOS)
        if #available(watchOS 6.0, *) {
            guard session.isCompanionAppInstalled else {
                self = .notReachable
                return
            }
        }
        #endif
        
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

#if os(watchOS)


extension PhoneState {
    
    init(session: WCSession) {
        self = .paired(.init(session: session))
    }
    
}

extension PhoneState.AppState {
    
    init(session: WCSession) {
        guard #available(watchOS 6.0, *) else {
            self = .installed
            return
        }
        if session.isCompanionAppInstalled {
            self = .installed
        } else {
            self = .notInstalled
        }
    }
    
}

#endif
