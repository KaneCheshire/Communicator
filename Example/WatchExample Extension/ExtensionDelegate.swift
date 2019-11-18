//
//  ExtensionDelegate.swift
//  WatchExample Extension
//
//  Created by Kane Cheshire on 19/07/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import ClockKit
import Communicator

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    // MARK: - WKExtensionDelegate -
    
    func applicationDidFinishLaunching() {
        setupObservers()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let task as WKWatchConnectivityRefreshBackgroundTask:
                Communicator.shared.task = task
            default: task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}

private extension ExtensionDelegate {
    
    func setupObservers() {
        setupActivationStateChangedObservers()
        setupReachabilityChangedObservers()
        setupMessageReceivedObservers()
        setupBlobReceivedObservers()
        setupContextUpdatedObservers()
        setupComplicationInfoObservers()
    }
    private func setupActivationStateChangedObservers() {
        Communicator.shared.activationStateChangedObservers.add { state in
            print("Activation state changed: ", state)
        }
    }
    
    private func setupReachabilityChangedObservers() {
        Communicator.shared.reachabilityChangedObservers.add { reachability in
            print("Reachability changed:", reachability)
        }
    }
    
    private func setupMessageReceivedObservers() {
        Communicator.shared.immediateMessageReceivedObservers.add { message in
            print("Received message: ", message.identifier)
            message.replyHandler?(["Replied!" : "Message"])
        }
    }
    
    private func setupBlobReceivedObservers() {
        Communicator.shared.blobReceivedObservers.add { blob in
            print("Received blob: ", blob.identifier)
        }
    }
    
    private func setupContextUpdatedObservers() {
        Communicator.shared.contextUpdatedObservers.add { context in
            print("Received context: ", context)
        }
    }
    
    private func setupComplicationInfoObservers() {
        Communicator.shared.complicationInfoReceivedObservers.add { complicationInfo in
            print("Received complication info: ", complicationInfo)
            CLKComplicationServer.sharedInstance().activeComplications?.forEach {
                CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
            }
        }
    }
    
}
