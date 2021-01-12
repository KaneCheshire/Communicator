//
//  CommunicatorSessionDelegate.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 20/11/2019.
//

import WatchConnectivity

/// Serves as the WCSessionDelegate to obfuscate the delegate methods.
final class SessionDelegate: NSObject, WCSessionDelegate {
    
    let communicator: Communicator
    var blobTransferCompletionHandlers: [WCSessionFileTransfer : Blob.Completion] = [:]
    var guaranteedMessageTransferCompletionHandlers: [WCSessionUserInfoTransfer : GuaranteedMessage.Completion] = [:]
    var complicationInfoTransferCompletionHandlers: [WCSessionUserInfoTransfer : ComplicationInfo.Completion] = [:]
    
    init(communicator: Communicator) {
        self.communicator = communicator
        super.init()
    }
    
    // MARK: - WCSessionDelegate -
    // MARK: Session status
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        Reachability.notifyObservers(communicator.currentReachability)
    }
    
    #if os(iOS)
    
    func sessionDidDeactivate(_ session: WCSession) {
        Reachability.notifyObservers(communicator.currentReachability)
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        Reachability.notifyObservers(communicator.currentReachability)
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        WatchState.notifyObservers(communicator.currentWatchState)
        Reachability.notifyObservers(communicator.currentReachability)
    }
    
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let state = Communicator.State(session: session.activationState)
        Communicator.State.notifyObservers(state)
        Reachability.notifyObservers(communicator.currentReachability)
        if activationState == .notActivated {
            session.activate()
        }
    }
    
    // MARK: Receiving messages
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let message = ImmediateMessage(content: message) else { return }
        ImmediateMessage.notifyObservers(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let message = InteractiveImmediateMessage(content: message, reply: { reply in
            replyHandler(reply.jsonRepresentation())
        }) else { return }
        InteractiveImmediateMessage.notifyObservers(message)
    }
    
    // MARK: Receiving and sending userInfo/complication data
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let message = GuaranteedMessage(content: userInfo) {
            GuaranteedMessage.notifyObservers(message)
        }
        #if os(watchOS)
        if let complicationInfo = ComplicationInfo(jsonDictionary: userInfo) {
            ComplicationInfo.notifyObservers(complicationInfo)
        }
        #endif
        endBackgroundTaskIfRequired()
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let handler = guaranteedMessageTransferCompletionHandlers[userInfoTransfer] {
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(()))
            }
        }
        #if os(iOS)
        if let handler = complicationInfoTransferCompletionHandlers[userInfoTransfer] {
            if let error = error {
                handler(.failure(error))
            } else {
                let numberOfUpdatesRemaining = communicator.currentWatchState.numberOfComplicationUpdatesAvailableToday
                handler(.success(numberOfUpdatesRemaining))
            }
        }
        #endif
    }
    
    // MARK: Receiving contexts
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let context = Context(content: applicationContext)
        Context.notifyObservers(context)
        endBackgroundTaskIfRequired()
    }
    
    // MARK: Receiving and sending files
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let data = try? Data(contentsOf: file.fileURL) else { return }
        guard let content = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any] else { return }
        guard let blob = Blob(content: content, metadata: file.metadata) else { return }
        Blob.notifyObservers(blob)
        endBackgroundTaskIfRequired()
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        guard let handler = blobTransferCompletionHandlers[fileTransfer] else { return }
        if let error = error {
            handler(.failure(error))
        } else {
            handler(.success(()))
        }
    }
    
    private func endBackgroundTaskIfRequired() {
        #if os(watchOS)
        guard !communicator.hasPendingDataToBeReceived else { return }
        if #available(watchOSApplicationExtension 4.0, *) {
            communicator.task?.setTaskCompletedWithSnapshot(true)
        } else {
            communicator.task?.setTaskCompleted()
        }
        #endif
    }
    
}
