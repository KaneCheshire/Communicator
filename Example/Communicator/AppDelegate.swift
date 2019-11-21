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
        setupObservations()
        return true
    }

}

private extension AppDelegate {
    
    func setupObservations() {
        Communicator.State.observe { state in
            print("Activation state changed: ", state)
        }
        WatchState.observe { watchState in
            print("Watch state changed: ", watchState)
        }
        Reachability.observe { reachability in
            print("Reachability changed:", reachability)
        }
        InteractiveImmediateMessage.observe { interactiveMessage in
            print("Received interactive message: ", interactiveMessage)
            let reply = ImmediateMessage(identifier: "reply")
            interactiveMessage.reply(reply)
        }
        ImmediateMessage.observe { immediateMessage in
            print("Received immediate message: ", immediateMessage)
        }
        GuaranteedMessage.observe { guaranteedMessage in
            print("Received guaranteed message: ", guaranteedMessage)
        }
        Blob.observe { blob in
            print("Received blob: ", blob)
        }
        Context.observe { context in
            print("Received context: ", context)
        }
    }
    
}

