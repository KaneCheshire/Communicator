//
//  Communicator.swift
//  Communicator
//
//  Created by Kane Cheshire on 12/07/2017.
//  Copyright © 2017 Kane Cheshire. All rights reserved.
//

import WatchConnectivity

public typealias JSONDictionary = [String : Any]

/// Handles communicating with a watchOS or iOS counterpart app by sending Messages, Contexts and Blobs.
public final class Communicator: NSObject {
    
    /// Represents an error that may occur.
    ///
    /// - sessionIsNotActive: Indicates the session is not currently active and cannot be used.
    public enum ErrorType: Error {
        case sessionIsNotActive
    }
    
    /// The shared communicaator object.
    public static let shared = Communicator()
    
    // MARK: - Properties -
    // MARK: Public
    
    /// Observers are notified when the communication session state changes.
    /// This may not be called on the main queue.
    public let activationStateChangedObservers = ObserverSet<WCSessionActivationState>()
    /// Observers are notified when the counterpart app becomes reachable or unreachable.
    /// This may not be called on the main queue.
    public let reachabilityChangedObservers = ObserverSet<Bool>()
    /// Observers are notified when a new Message is received.
    /// This may not be called on the main queue.
    public let messageReceivedObservers = ObserverSet<Message>()
    /// Observers are notified when a new Blob is received.
    /// This may not be called on the main queue.
    public let blobReceivedObservers = ObserverSet<Blob>()
    /// Observers are notified when a new Context is received.
    /// This may not be called on the main queue.
    public let contextUpdatedObservers = ObserverSet<Context>()
    /// This can be queried for the latest Context that has been received on this device.
    /// The Context may have empty content if no Context has been received from 
    /// the counterpart.
    public var mostRecentlyReceievedContext: Context {
        return Context(content: session.receivedApplicationContext)
    }
    /// This can be queried for the latest Context that has been sent by this device.
    /// The Context may have empty content if no Context has been sent from this device.
    public var mostRecentlySentContext: Context {
        return Context(content: session.applicationContext)
    }
    
    #if os(iOS)
    
    /// Observers are notified when the communication session detects a WatchState change.
    /// This can mean the user has enabled a complication or installed the watch app, for example.
    public let watchStateUpdatedObservers = ObserverSet<WatchState>()
    
    #endif
    
    // MARK: Private
    
    private let session: WCSession = .default()
    private lazy var sessionDelegate: CommunicatorSessionDelegate = {
        return CommunicatorSessionDelegate(communicator: self)
    }()
    private var canCommunicate: Bool {
        return session.isReachable && session.activationState != .notActivated
    }
    fileprivate var blobTransferCompletionHandlers: [WCSessionFileTransfer : Blob.CompletionHandler] = [:]
    
    // MARK: - Initialisers -
    // MARK: Public
    
    override init() {
        super.init()
        session.delegate = sessionDelegate
        session.activate()
    }
    
    // MARK: - Functions -
    // MARK: Public
    
    /// Sends a Message immediately to the counterpart app.
    /// If an immediate error occurs this message will throw an error.
    /// If an error occurs after the Message transfer is attempted, the Message's error handler
    /// will be called, if there is one.
    /// Do not use Messages for sending large amounts of data, transfer a Blob instead.
    ///
    /// - Parameter immediateMessage: The Message to send immediately to the counterpart app.
    /// - Throws: ErrorType
    public func send(immediateMessage: Message) throws {
        guard session.activationState == .activated else { throw ErrorType.sessionIsNotActive }
        session.sendMessage(immediateMessage.jsonRepresentation(), replyHandler: immediateMessage.replyHandler, errorHandler: immediateMessage.errorHandler)
    }
    
    /// Sends a guaranteed Message to the counterpart app.
    /// Guaranteed messages are queued and deliverd to the counterpart in the order they were
    /// queued.
    /// This means that you may get a stream of these messages after your app is launched.
    /// Do not use Messages for sending large amounts of data, transfer a Blob instead.
    ///
    /// - Parameter guaranteedMessage: The Message to queue and send to the counterpart app.
    /// - Throws: ErrorType
    public func transfer(guaranteedMessage: Message) throws {
        guard session.activationState == .activated else { throw ErrorType.sessionIsNotActive }
        session.transferUserInfo(guaranteedMessage.jsonRepresentation())
    }
    
    /// Transfers a Blob to the counterpart app.
    /// Blobs are better suited for sending large amounts of data.
    /// The system will continue to send this data after the sending device exits if
    /// necessary. The system can throttle Blob transfers if needed, so transfer speeds
    /// are not guaranteed.
    ///
    /// - Parameter blob: <#blob description#>
    /// - Throws: <#throws value description#>
    public func transfer(blob: Blob) throws {
        guard session.activationState == .activated else { throw ErrorType.sessionIsNotActive }
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let urlString = documentsDirectory.appending("/blob.data")
        let fileURL = URL(fileURLWithPath: urlString)
        try blob.dataRepresentation().write(to: fileURL)
        let transfer = session.transferFile(fileURL, metadata: nil)
        blobTransferCompletionHandlers[transfer] = blob.completionHandler
    }
    
    /// Syncs a Context with the counterpart app. Contexts are lightweight and should not be used for messaging
    /// or transferring large amounts of data.
    /// Contexts are perfect for syncing things like preferences. You can query the latest Context at any time
    /// with the`mostRecentlyReceievedContext` and `mostRecentlySentContext` properties of the shared
    /// Communicator object.
    ///
    /// - Parameter context: The Context to sync with the counterpart app.
    /// - Throws: ErrorType
    public func sync(context: Context) throws {
        guard session.activationState == .activated else { throw ErrorType.sessionIsNotActive }
        try session.updateApplicationContext(context.content)
    }
    
}

/// Serves as the WCSessionDelegate to obfuscate the delegate methods.
private final class CommunicatorSessionDelegate: NSObject, WCSessionDelegate {
    
    weak var communicator: Communicator?
    
    init(communicator: Communicator) {
        self.communicator = communicator
        super.init()
    }
    
    // MARK: - WCSessionDelegate -
    // MARK: Session status
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        communicator?.reachabilityChangedObservers.notify(session.isReachable)
    }
    
    #if os(iOS)
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        if #available(iOS 10.0, *) {
            let watchState = WatchState(isPaired: session.isPaired, isWatchAppInstalled: session.isWatchAppInstalled, isComplicationEnabled: session.isComplicationEnabled, numberOfComplicationUserInfoTransfersAvailable: session.remainingComplicationUserInfoTransfers, watchSpecificDirectoryURL: session.watchDirectoryURL)
            communicator?.watchStateUpdatedObservers.notify(watchState)
        } else {
            let watchState = WatchState(isPaired: session.isPaired, isWatchAppInstalled: session.isWatchAppInstalled, isComplicationEnabled: session.isComplicationEnabled, numberOfComplicationUserInfoTransfersAvailable: -1, watchSpecificDirectoryURL: session.watchDirectoryURL)
            communicator?.watchStateUpdatedObservers.notify(watchState)
        }
    }
    
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        communicator?.activationStateChangedObservers.notify(activationState)
        guard activationState == .activated else { return }
        session.activate()
    }
    
    // MARK: Receiving messages
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let message = try? Message(jsonDictionary: message) else { return }
        communicator?.messageReceivedObservers.notify(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let message = try? Message(jsonDictionary: message, replyHandler: replyHandler) else { return replyHandler(["error":"unableToConstructMessageFromJSON"]) }
        communicator?.messageReceivedObservers.notify(message)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {}
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) { replyHandler(Data()) }
    
    // MARK: Receiving and sending userInfo/complication data
    
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let message = try? Message(jsonDictionary: userInfo) else { return }
        communicator?.messageReceivedObservers.notify(message)
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("Finished sending userInfoTransfer \(userInfoTransfer) \(error?.localizedDescription ?? "")")
    }
    
    // MARK: Receiving contexts
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        communicator?.contextUpdatedObservers.notify(Context(content: applicationContext))
    }
    
    // MARK: Receiving and sending files
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let data = try? Data(contentsOf: file.fileURL) else { return }
        guard let messageDictionary: [String : Any] = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any] else { return }
        guard let blob = try? Blob(jsonDictionary: messageDictionary) else { return }
        communicator?.blobReceivedObservers.notify(blob)
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        let handler = communicator?.blobTransferCompletionHandlers[fileTransfer]
        handler?(error)
    }
    
}
