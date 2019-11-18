//
//  InterfaceController.swift
//  WatchExample Extension
//
//  Created by Kane Cheshire on 19/07/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Communicator

class InterfaceController: WKInterfaceController {
    
    @IBAction func sendMessageTapped() {
        let message = ImmediateMessage(identifier: "message", content: ["hello" : "world"], replyHandler: { replyJSON in
            print("Received reply from message: \(replyJSON)")
        })
        try? Communicator.shared.send(message)
    }
    
    @IBAction func transferBlobTapped() {
        let data = "hello world".data(using: .utf8) ?? Data()
        let blob = Blob(identifier: "blob", content: data)
        try? Communicator.shared.transfer(blob) { result in
            switch result {
                case .failure(let error): print("Error transferring blob: \(error.localizedDescription)")
                case .success: print("Successfully transferred blob to phone")
            }
        }
    }
    
    @IBAction func syncContextTapped() {
        let context = Context(content: ["hello" : "world"])
        do {
            try Communicator.shared.sync(context)
            print("Synced context to phone")
        } catch let error {
            print("Error syncing context to phone: \(error.localizedDescription)")
        }
    }
    

}
