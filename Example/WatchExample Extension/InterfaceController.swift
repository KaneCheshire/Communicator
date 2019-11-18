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
        let message = ImmediateMessage(identifier: "message", content: ["hello" : "world"]) { reply in
            print("Received reply from message: \(reply)")
        }
        Communicator.shared.send(message)
    }
    
    @IBAction func sendGuaranteedMessageTapped() {
        let message = GuaranteedMessage(identifier: "guaranteed message", content: ["message": "content"])
        Communicator.shared.send(message) { result in
           switch result {
                case .failure(let error):
                    print("Error transferring blob: \(error.localizedDescription)")
                case .success:
                    print("Successfully transferred guaranteed message to phone")
            }
        }
    }
    
    @IBAction func transferBlobTapped() {
        let data = Data("hello world".utf8)
        let blob = Blob(identifier: "blob", content: data)
        Communicator.shared.transfer(blob) { result in
            switch result {
                case .failure(let error):
                    print("Error transferring blob: \(error.localizedDescription)")
                case .success:
                    print("Successfully transferred blob to phone")
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
