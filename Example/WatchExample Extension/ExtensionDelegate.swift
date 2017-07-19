//
//  ExtensionDelegate.swift
//  WatchExample Extension
//
//  Created by Kane Cheshire on 19/07/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Communicator

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        setupObservers()
    }

}

private extension ExtensionDelegate {
    
    func setupObservers() {
        setupActivationStateChangedObservers()
        setupReachabilityChangedObservers()
        setupMessageReceivedObservers()
        setupBlobReceivedObservers()
        setupContextUpdatedObservers()
    }
    
    private func setupActivationStateChangedObservers() {
        Communicator.shared.activationStateChangedObservers.add { state in
            print("Activation state changed: \(state.rawValue)")
        }
    }
    
    private func setupReachabilityChangedObservers() {
        Communicator.shared.reachabilityChangedObservers.add { isReachable in
            print("Reachability changed: \(isReachable ? "is" : "is not") reachable")
        }
    }
    
    private func setupMessageReceivedObservers() {
        Communicator.shared.messageReceivedObservers.add { message in
            print("Received message: \(message)")
            message.replyHandler?(["Replied!" : "Message"])
        }
    }
    
    private func setupBlobReceivedObservers() {
        Communicator.shared.blobReceivedObservers.add { blob in
            print("Received blob: \(blob.identifier)")
        }
    }
    
    private func setupContextUpdatedObservers() {
        Communicator.shared.contextUpdatedObservers.add { context in
            print("Received context: \(context)")
        }
    }
    
}
