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
        let message = InteractiveImmediateMessage(identifier: "message", content: ["hello": "world"]) { reply in
            print("Received reply from message: \(reply)")
        }
        Communicator.shared.send(message) { error in
            print("Error sending immediate message", error)
        }
    }
    
    @IBAction func sendGuaranteedMessageTapped() {
        let message = GuaranteedMessage(identifier: "guaranteed message", content: ["message": "content"])
        Communicator.shared.send(message) { result in
           switch result {
                case .failure(let error):
                    print("Error transferring blob: \(error.localizedDescription)")
                case .success:
                    print("Successfully transferred guaranteed message to watch")
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
                    print("Successfully transferred blob to watch")
            }
        }
    }
    
    @IBAction func syncContextTapped() {
        let context = Context(content: ["hello" : "world"])
        do {
            try Communicator.shared.sync(context)
            print("Synced context to watch")
        } catch let error {
            print("Error syncing context to watch: \(error.localizedDescription)")
        }
    }
    
    @IBAction func transferComplicationInfoTapped() {
        switch Communicator.shared.currentWatchState {
            case .notPaired:
                print("Watch is not paired, cannot transfer complication info")
            case .paired(let appState):
                switch appState {
                    case .notInstalled:
                        print("App is not installed, cannot transfer complication info")
                    case .installed(let compState, _):
                        switch compState {
                            case .notEnabled:
                                print("Complication is not enabled on the active watch face, cannot transfer complication info")
                            case .enabled(let numberOfComplicationUpdatesAvailable):
                                print("Number of complication transfers available today (usually out of 50)", numberOfComplicationUpdatesAvailable)
                                transferCompInfo()
                    }
            }
        }
    }
    
    private func transferCompInfo() {
        let complicationInfo = ComplicationInfo(content: ["Value" : 1])
        Communicator.shared.transfer(complicationInfo) { result in
            switch result {
                case .success(let numberOfComplicationUpdatesAvailable):
                    print("Successfully transferred complication info, number of complications now available: ", numberOfComplicationUpdatesAvailable)
                case .failure(let error):
                    print("Failed to transfer complication info", error.localizedDescription)
            }
            
        }
    }
    
}

