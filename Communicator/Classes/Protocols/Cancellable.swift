//
//  Cancellable.swift
//  Pods
//
//  Created by Kane Cheshire on 20/11/2019.
//

import WatchConnectivity

public protocol Cancellable {
    
    /// Cancels the task.
    func cancel()
    
}

extension WCSessionUserInfoTransfer: Cancellable {}
extension WCSessionFileTransfer: Cancellable {}
