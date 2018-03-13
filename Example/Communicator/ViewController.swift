//
//  ViewController.swift
//  Communicator
//
//  Created by Kane Cheshire on 07/19/2017.
//  Copyright (c) 2017 Kane Cheshire. All rights reserved.
//

import UIKit
import Communicator

class ViewController: UIViewController {

    @IBAction func sendMessageTapped() {
        let message = ImmediateMessage(identifier: "message", content: ["hello" : "world"], replyHandler: { replyJSON in
            print("Received reply from message: \(replyJSON)")
        })
        try? Communicator.shared.send(immediateMessage: message)
    }
    
    @IBAction func transferBlobTapped() {
        let data = "hello world".data(using: .utf8) ?? Data()
        let blob = Blob(identifier: "blob", content: data, completionHandler: { error in
            if let error = error {
                print("Error transferring blob: \(error.localizedDescription)")
            } else {
                print("Successfully transferred blob to watch")
            }
        })
        try? Communicator.shared.transfer(blob: blob)
    }
    
    @IBAction func syncContextTapped() {
        let context = Context(content: ["hello" : "world"])
        do {
            try Communicator.shared.sync(context: context)
            print("Synced context to watch")
        } catch let error {
            print("Error syncing context to watch: \(error.localizedDescription)")
        }
    }
    
    @IBAction func transferComplicationInfoTapped() {
        let complicationInfo = ComplicationInfo(content: ["Value" : 1])
        try? Communicator.shared.transfer(complicationInfo: complicationInfo)
        print("Number of complication transfers available today: \(Communicator.shared.currentWatchState.numberOfComplicationInfoTransfersAvailable)")
    }
    
}

