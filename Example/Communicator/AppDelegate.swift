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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupObservers()
        return true
    }

}

private extension AppDelegate {
    
    func setupObservers() {
        setupActivationStateChangedObservers()
        setupWatchStateChangedObservers()
        setupReachabilityChangedObservers()
        setupImmediateMessageReceivedObservers()
        setupBlobReceivedObservers()
        setupContextUpdatedObservers()
    }
    
    private func setupActivationStateChangedObservers() {
        Communicator.shared.activationStateChangedObservers.add { state in
            print("Activation state changed: ", state)
        }
    }
    
    private func setupWatchStateChangedObservers() {
        Communicator.shared.watchStateUpdatedObservers.add { watchState in
           print("Watch state changed: ", watchState)
        }
    }
    
    private func setupReachabilityChangedObservers() {
        Communicator.shared.reachabilityChangedObservers.add { reachability in
            print("Reachability changed: ", reachability)
        }
    }
    
    private func setupImmediateMessageReceivedObservers() {
        Communicator.shared.immediateMessageReceivedObservers.add { message in
            print("Received message: ", message)
            message.reply?(["Reply" : "Message"])
        }
        Communicator.shared.guaranteedMessageReceivedObservers.add { message in
            print("Received message: ", message)
        }
    }
    
    private func setupBlobReceivedObservers() {
        Communicator.shared.blobReceivedObservers.add { blob in
            print("Received blob: ", blob)
        }
    }
    
    private func setupContextUpdatedObservers() {
        Communicator.shared.contextUpdatedObservers.add { context in
            print("Received context: ", context)
        }
    }
    
}

