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

    // MARK: - Properties -
    // MARK: Fileprivate
    
    fileprivate var watchConnectivityTask: WKWatchConnectivityRefreshBackgroundTask? {
        didSet {
            print("watchConnectivityTask set")
            oldValue?.setTaskCompleted()
        }
    }
    
    // MARK: - WKExtensionDelegate -
    
    func applicationDidFinishLaunching() {
        setupObservers()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let task as WKApplicationRefreshBackgroundTask:
                task.setTaskCompleted()
            case let task as WKSnapshotRefreshBackgroundTask:
                task.setTaskCompleted(restoredDefaultState: false, estimatedSnapshotExpiration: .distantFuture, userInfo: nil)
            case let task as WKURLSessionRefreshBackgroundTask:
                task.setTaskCompleted()
            case let task as WKWatchConnectivityRefreshBackgroundTask:
                watchConnectivityTask = task
            default:
                assertionFailure("Unhandled task!")
                task.setTaskCompleted()
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
            self.endWatchConnectivityBackgroundTaskIfNecessary()
        }
    }
    
    private func setupBlobReceivedObservers() {
        Communicator.shared.blobReceivedObservers.add { blob in
            print("Received blob: ", blob.identifier)
            self.endWatchConnectivityBackgroundTaskIfNecessary()
        }
    }
    
    private func setupContextUpdatedObservers() {
        Communicator.shared.contextUpdatedObservers.add { context in
            print("Received context: ", context)
            self.endWatchConnectivityBackgroundTaskIfNecessary()
        }
    }
    
    private func setupComplicationInfoObservers() {
        Communicator.shared.complicationInfoReceivedObservers.add { complicationInfo in
            print("Received complication info: ", complicationInfo)
            CLKComplicationServer.sharedInstance().activeComplications?.forEach {
                CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
            }
            self.endWatchConnectivityBackgroundTaskIfNecessary()
        }
    }
    
    private func endWatchConnectivityBackgroundTaskIfNecessary() {
        // First check we're not expecting more data
        guard !Communicator.shared.hasPendingDataToBeReceived else { return }
        // And then end the task (if there is one!)
        self.watchConnectivityTask?.setTaskCompleted()
    }
    
}
