//
//  WatchConnectivity+Helpers.swift
//  Pods
//
//  Created by Kane Cheshire on 20/07/2017.
//
//

import WatchConnectivity

extension WCSessionActivationState {
    
    var equivalentCommunicatorState: Communicator.State {
        switch self {
        case .notActivated: return .notActivated
        case .inactive: return .inactive
        case .activated: return .activated
        }
    }
    
}
