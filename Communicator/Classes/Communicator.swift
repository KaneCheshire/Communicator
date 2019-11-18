//
//  Communicator.swift
//  Communicator
//
//  Created by Kane Cheshire on 12/07/2017.
//  Copyright © 2017 Kane Cheshire. All rights reserved.
//

import WatchConnectivity
import TABObserverSet
#if os(watchOS)
import WatchKit
#endif

public typealias Content = [String : Any]

/// Handles communicating with a watchOS or iOS counterpart app by sending Messages, Contexts and Blobs.
public final class Communicator: NSObject {
    
    /// Represents an error that may occur.
    ///
    /// - sessionIsNotActive: Indicates the session is not currently active and cannot be used.
    public enum Error: Swift.Error {
        case sessionIsNotReachable
    }
    
    /// Represents the current state of the communcation session.
    ///
    /// - notActivated: The communication has not been activated yet.
    /// - inactive: The communication has been activated but is currently inactive.
    /// - activated: The communication session is activated and usable.
    public enum State {
        case notActivated
        case inactive
        case activated
    }
    
    /// Represents the current reachability of the counteroart app..
    ///
    /// - notReachable: The counterpart app is not reachable at all.
    /// - backgroundMessaging: The counterpart app is reachable but only for background messaging types. (i.e Blobs and GuaranteedMessages)
    /// - immediateMessaging: The counterpart app is available for all types of messaging.
    public enum Reachability {
        case notReachable
        case backgroundMessaging
        case immediateMessaging
    }
    
    /// The shared communicaator object.
    public static let shared = Communicator()
    
    // MARK: - Properties -
    // MARK: Public
    
    public var currentState: State {
        return session.activationState.equivalentCommunicatorState
    }
    
    public var currentReachability: Reachability {
        switch (session.activationState, session.isReachable) {
        case (.activated, true): return .immediateMessaging
        case (.activated, false): return .backgroundMessaging
        default: return .notReachable
        }
    }
    
    /// Observers are notified when the communication session state changes.
    /// This may not be called on the main queue.
    public let activationStateChangedObservers = ObserverSet<State>()
    
    /// Observers are notified when the counterpart app becomes reachable or unreachable.
    /// This may not be called on the main queue.
    public let reachabilityChangedObservers = ObserverSet<Reachability>()
    
    /// Observers are notified when a new ImmediateMessage is received.
    /// This may not be called on the main queue.
    public let immediateMessageReceivedObservers = ObserverSet<ImmediateMessage>()
    
    /// Observers are notified when a new GuaranteedMessage is received.
    /// This may not be called on the main queue.
    public let guaranteedMessageReceivedObservers = ObserverSet<GuaranteedMessage>()
    
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
    
    /// Whether the underlying session still has data to send you.
    public var hasPendingDataToBeReceived: Bool {
        return session.hasContentPending
    }
    
    #if os(iOS)
    
    /// Observers are notified when the communication session detects a WatchState change.
    /// This can mean the user has enabled a complication or installed the watch app, for example.
    public let watchStateUpdatedObservers = ObserverSet<WatchState>()
    
    /// Can be queried to return the current watch state, i.e. whether it's paired etc.
    public var currentWatchState: WatchState {
        return WatchState(isPaired: session.isPaired, isWatchAppInstalled: session.isWatchAppInstalled, isComplicationEnabled: session.isComplicationEnabled, numberOfComplicationInfoTransfersAvailable: session.remainingComplicationUserInfoTransfers, watchSpecificDirectoryURL: session.watchDirectoryURL)
    }
    
    #endif
    
    #if os(watchOS)
    
    /// Observers are notified when a new ComplicationInfo has been received.
    public let complicationInfoReceivedObservers = ObserverSet<ComplicationInfo>()
    
    /// If set, this task will automatically be ended when any background data has finished been received.
    /// You must set this from your ExtensionDelegate when you receive one from the system.
    public var task: WKWatchConnectivityRefreshBackgroundTask?
    
    #endif
    
    // MARK: Private
    
    private let session: WCSession = .default
    private lazy var sessionDelegate = CommunicatorSessionDelegate(communicator: self)
    fileprivate var blobTransferCompletionHandlers: [WCSessionFileTransfer : Blob.Completion] = [:]
    fileprivate var guaranteedMessageTransferCompletionHandlers: [WCSessionUserInfoTransfer : GuaranteedMessage.Completion] = [:]
    fileprivate var complicationInfoTransferCompletionHandlers: [WCSessionUserInfoTransfer : ComplicationInfo.Completion] = [:]
    
    // MARK: - Initialisers -
    // MARK: Public
    
    override init() {
        super.init()
        session.delegate = sessionDelegate
        session.activate()
    }
    
    // MARK: - Functions -
    // MARK: Public
    
    /// Sends a message immediately to the counterpart app.
    ///
    /// If an error occurs before sending the message, this function will throw an error.
    /// If an error occurs after the ImmediateMessage transfer is attempted, the ImmediateMessage's error handler
    /// will be called, if there is one.
    /// Do not use ImmediateMessage for sending large amounts of data, transfer a Blob instead.
    ///
    /// - Parameter immediateMessage: The ImmediateMessage to send immediately to the counterpart app.
    public func send(_ immediateMessage: ImmediateMessage, errorHandler: ImmediateMessage.ErrorHandler? = nil) {
        guard currentReachability == .immediateMessaging else {
            errorHandler?(Error.sessionIsNotReachable)
            return
        }
        session.sendMessage(immediateMessage.jsonRepresentation(), replyHandler: immediateMessage.reply, errorHandler: errorHandler)
    }
    
    /// Sends a guaranteed message to the counterpart app.
    /// GuaranteedMessages do not require the counterpart app to be reachable, as the system sends them at an "opportune" time.
    /// GuaranteedMessages are queued and delivered to the counterpart in the order they were
    /// queued.
    /// This means that you may get a stream of these messages after your app is launched.
    ///
    /// If an error occurs before sending the message, this function will throw an error.
    /// Do not use GuaranteedMessages for sending large amounts of data, transfer a Blob instead.
    ///
    /// - Parameter guaranteedMessage: The GuaranteedMessages to queue and send to the counterpart app.
    /// - Parameter completiob: An optional completion handler that is executed when the transfer fails or succeeds.
    public func send(_ guaranteedMessage: GuaranteedMessage, completion: GuaranteedMessage.Completion? = nil) {
        switch currentReachability {
            case .backgroundMessaging, .immediateMessaging:
                let transfer = session.transferUserInfo(guaranteedMessage.jsonRepresentation())
                guaranteedMessageTransferCompletionHandlers[transfer] = completion
            case .notReachable:
                completion?(.failure(Error.sessionIsNotReachable))
        }
    }
    
    /// Transfers a Blob to the counterpart app.
    /// Blobs are better suited for sending large amounts of data.
    /// The system will continue to send this data after the sending device exits if
    /// necessary. The system can throttle Blob transfers if needed, so transfer speeds
    /// are not guaranteed.
    ///
    /// If an error occurs before transferring the Blob, this function will throw an error.
    ///
    /// - Parameter blob: The Blob to transfer.
    /// - Parameter completion: An optional handler that is called when the transfer completes or fails.
    public func transfer(_ blob: Blob, completion: Blob.Completion? = nil) {
        switch currentReachability {
            case .backgroundMessaging, .immediateMessaging:
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let urlString = documentsDirectory.appending("/blob.data")
                let fileURL = URL(fileURLWithPath: urlString)
                do {
                    try blob.dataRepresentation().write(to: fileURL)
                    let transfer = session.transferFile(fileURL, metadata: nil)
                    blobTransferCompletionHandlers[transfer] = completion
                } catch {
                    completion?(.failure(error))
                }
            case .notReachable:
                completion?(.failure(Error.sessionIsNotReachable))
        }
    }
    
    /// Syncs a Context with the counterpart app. Contexts are lightweight and should not be used for messaging
    /// or transferring large amounts of data.
    /// Contexts are perfect for syncing things like preferences. You can query the latest Context at any time
    /// with the`mostRecentlyReceievedContext` and `mostRecentlySentContext` properties of the shared
    /// Communicator object.
    ///
    /// If an error occurs before syncing the context, this function will throw an error.
    ///
    /// - Parameter context: The Context to sync with the counterpart app.
    public func sync(_ context: Context) throws {
        switch currentReachability {
            case .backgroundMessaging, .immediateMessaging:
                try session.updateApplicationContext(context.content)
            case .notReachable:
                throw Error.sessionIsNotReachable
        }
    }
    
    #if os(iOS)
    
    /// Starts the transfer of a ComplicationInfo to a watchOS app. If the watchOS app is reachable
    /// and the per-day limit of sending ComplicationInfo has not been reached, this method wakes
    /// up your watchOS app in the background to process it. 
    ///
    /// If the limit for sending ComplicationInfo updates has been reached, the system queues the transfer
    /// and will deliver it when the app is next brought into the foreground or when the per-day count
    /// gets reset.
    ///
    /// Starting from iOS 10, you can query the remaining number of transfers available for the day by
    /// checking the currentWatchState property.
    ///
    /// - Parameter complicationInfo: The ComplicationInfo to transfer.
    /// - Parameter completion: An optional handler that is called when the transfer completes or fails.
    public func transfer(_ complicationInfo: ComplicationInfo, completion: ComplicationInfo.Completion? = nil) {
        switch currentReachability {
            case .backgroundMessaging, .immediateMessaging:
                let transfer = session.transferCurrentComplicationUserInfo(complicationInfo.jsonRepresentation())
                complicationInfoTransferCompletionHandlers[transfer] = completion
            case .notReachable:
                completion?(.failure(Error.sessionIsNotReachable))
        }
    }
    
    #endif
    
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
        communicator?.reachabilityChangedObservers.notify(communicator?.currentReachability ?? .notReachable)
    }
    
    #if os(iOS)
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
        communicator?.reachabilityChangedObservers.notify(communicator?.currentReachability ?? .notReachable)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        communicator?.reachabilityChangedObservers.notify(communicator?.currentReachability ?? .notReachable)
    } // Required
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        guard let watchState = communicator?.currentWatchState else { return }
        communicator?.watchStateUpdatedObservers.notify(watchState)
        communicator?.reachabilityChangedObservers.notify(communicator?.currentReachability ?? .notReachable)
    }
    
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        communicator?.activationStateChangedObservers.notify(activationState.equivalentCommunicatorState)
        communicator?.reachabilityChangedObservers.notify(communicator?.currentReachability ?? .notReachable)
        guard activationState != .activated else { return }
        session.activate()
    }
    
    // MARK: Receiving messages
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let message = try? ImmediateMessage(content: message, reply: nil) else { return }
        communicator?.immediateMessageReceivedObservers.notify(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let message = try? ImmediateMessage(content: message, reply: replyHandler) else { return replyHandler(["error":"unableToConstructMessageFromJSON"]) }
        communicator?.immediateMessageReceivedObservers.notify(message)
    }
    
    // MARK: Receiving and sending userInfo/complication data
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let message = try? GuaranteedMessage(content: userInfo) {
            communicator?.guaranteedMessageReceivedObservers.notify(message)
        }
        #if os(watchOS)
        if let complicationInfo = try? ComplicationInfo(jsonDictionary: userInfo) {
            communicator?.complicationInfoReceivedObservers.notify(complicationInfo)
        }
        #endif
        endBackgroundTaskIfRequired()
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let handler = communicator?.guaranteedMessageTransferCompletionHandlers[userInfoTransfer] {
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(()))
            }
        } else if let handler = communicator?.complicationInfoTransferCompletionHandlers[userInfoTransfer] {
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(()))
            }
        }
    }
    
    // MARK: Receiving contexts
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        communicator?.contextUpdatedObservers.notify(Context(content: applicationContext))
        endBackgroundTaskIfRequired()
    }
    
    // MARK: Receiving and sending files
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let data = try? Data(contentsOf: file.fileURL) else { return }
        guard let content = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any] else { return }
        guard let blob = try? Blob(content: content) else { return }
        communicator?.blobReceivedObservers.notify(blob)
        endBackgroundTaskIfRequired()
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        guard let handler = communicator?.blobTransferCompletionHandlers[fileTransfer] else { return }
        if let error = error {
            handler(.failure(error))
        } else {
            handler(.success(()))
        }
    }
    
    private func endBackgroundTaskIfRequired() {
        #if os(watchOS)
        guard communicator?.hasPendingDataToBeReceived == false else { return }
        if #available(watchOSApplicationExtension 4.0, *) {
            communicator?.task?.setTaskCompletedWithSnapshot(true)
        } else {
            communicator?.task?.setTaskCompleted()
        }
        #endif
    }
    
}
