//
//  AppDelegate.swift
//  Communicator
//
//  Created by Kane Cheshire on 07/19/2017.
//  Copyright (c) 2017 Kane Cheshire. All rights reserved.
//

import UIKit
import Communicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupObservers()
        return true
    }

}

private extension AppDelegate {
    
    func setupObservers() {
        setupActivationStateChangedObservers()
        setupWatchStateChangedObservers()
        setupReachabilityChangedObservers()
        setupMessageReceivedObservers()
        setupBlobReceivedObservers()
        setupContextUpdatedObservers()
    }
    
    private func setupActivationStateChangedObservers() {
        Communicator.shared.activationStateChangedObservers.add { state in
            print("Activation state changed: \(state)")
        }
    }
    
    private func setupWatchStateChangedObservers() {
        Communicator.shared.watchStateUpdatedObservers.add { watchState in
           print("Watch state changed: \(watchState)")
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
            message.replyHandler?(["Reply" : "Message"])
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

