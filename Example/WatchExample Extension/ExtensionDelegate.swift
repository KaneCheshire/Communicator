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
        setupObservations()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
                case let task as WKWatchConnectivityRefreshBackgroundTask:
                    Communicator.shared.task = task // Let Communicator handle the task!
                default: task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
}

private extension ExtensionDelegate {
    
    func setupObservations() {
        Communicator.State.observe { state in
            print("Activation state changed: ", state)
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
        ComplicationInfo.observe { complicationInfo in
            print("Received complication info: ", complicationInfo)
            self.reloadAllComplications()
        }
    }
    
    private func reloadAllComplications() {
        CLKComplicationServer.sharedInstance().activeComplications?.forEach {
            CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
        }
    }
    
}
