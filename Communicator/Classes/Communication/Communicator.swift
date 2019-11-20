//
//  Communicator.swift
//  Communicator
//
//  Created by Kane Cheshire on 12/07/2017.
//  Copyright © 2017 Kane Cheshire. All rights reserved.
//

import WatchConnectivity
#if os(watchOS)
import WatchKit
#endif

/// Handles communicating with a watchOS or iOS counterpart app by sending Messages, Contexts and Blobs.
public final class Communicator: NSObject {
    
    /// Represents an error that may occur.
    ///
    /// - sessionIsNotActive: Indicates the session is not currently active and cannot be used.
    public enum Error: Swift.Error {
        case sessionIsNotReachable(minimumReachability: Reachability, actual: Reachability)
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
    
    /// The shared communicaator object.
    public static let shared = Communicator()
    
    public var currentState: State {
        return State(session: session.activationState)
    }
    
    public var currentReachability: Reachability {
        return Reachability(session: session)
    }
    
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
    
    /// Can be queried to return the current watch state, i.e. whether it's paired etc.
    public var currentWatchState: WatchState {
        return WatchState(session: session)
    }
    
    #endif
    
    #if os(watchOS)
    
    /// If set, this task will automatically be ended when any background data has finished been received.
    /// You must set this from your ExtensionDelegate when you receive one from the system.
    public var task: WKWatchConnectivityRefreshBackgroundTask?
    
    #endif
    
    private let session: WCSession = .default
    private lazy var sessionDelegate = SessionDelegate(communicator: self)
    
    override init() {
        super.init()
        session.delegate = sessionDelegate
        session.activate()
    }
    
    /// Sends a message immediately to the counterpart app.
    ///
    /// If an error occurs after the ImmediateMessage transfer is attempted, the error handler
    /// will be called, if there is one provided.
    /// Do not use ImmediateMessage for sending large amounts of data, transfer a Blob instead.
    ///
    /// The current reachability must be .immediatelyReachable.
    ///
    /// - Parameter immediateMessage: The message to send immediately to the counterpart app.
    /// - Parameter errorHandler: An optional error handler that is called upon failure for any reason.
    public func send(_ immediateMessage: ImmediateMessage, errorHandler: ImmediateMessage.ErrorHandler? = nil) {
        guard currentReachability == .immediatelyReachable else {
            errorHandler?(Error.sessionIsNotReachable(minimumReachability: .immediatelyReachable, actual: currentReachability))
            return
        }
        session.sendMessage(immediateMessage.jsonRepresentation(), replyHandler: nil, errorHandler: errorHandler)
    }
    
    /// Sends an interactive message immediately. Interactive messages have a reply handler that is executed on the receiving end.
    ///
    /// If an error occurs after the ImmediateMessage transfer is attempted, the error handler
    /// will be called, if there is one provided.
    /// Do not use InteractiveImmediateMessage for sending large amounts of data, transfer a Blob instead.
    ///
    /// The current reachability must be .immediateMessaging.
    ///
    /// - Parameters:
    ///   - interactiveImmediateMessage: The interactive message to send immediately to the counterpart app.
    ///   - errorHandler: An optional error handler that is called upon failure for any reason.
    public func send(_ interactiveImmediateMessage: InteractiveImmediateMessage, errorHandler: ImmediateMessage.ErrorHandler? = nil) {
        guard currentReachability == .immediatelyReachable else {
            errorHandler?(Error.sessionIsNotReachable(minimumReachability: .immediatelyReachable, actual: currentReachability))
            return
        }
        session.sendMessage(interactiveImmediateMessage.jsonRepresentation(), replyHandler: { content in
            guard let message = ImmediateMessage(content: content) else { return }
            interactiveImmediateMessage.reply(message)
        }, errorHandler: errorHandler)
    }
    
    /// Sends a guaranteed message to the counterpart app.
    /// GuaranteedMessages do not require the counterpart app to be reachable, as the system sends them at an "opportune" time.
    /// GuaranteedMessages are queued and delivered to the counterpart in the order they were
    /// queued.
    /// This means that you may get a stream of these messages after your app is launched.
    ///
    /// Do not use GuaranteedMessages for sending large amounts of data, transfer a Blob instead.
    ///
    /// The current reachability must not be .notReachable.
    ///
    /// This function returns a cancellable object that you can use to cancel the transfer before it is complete.
    ///
    /// - Parameter guaranteedMessage: The GuaranteedMessages to queue and send to the counterpart app.
    /// - Parameter completion: An optional completion handler that is executed when the transfer fails or succeeds.
    @discardableResult
    public func send(_ guaranteedMessage: GuaranteedMessage, completion: GuaranteedMessage.Completion? = nil) -> Cancellable? {
        guard currentReachability != .notReachable  else {
            completion?(.failure(Error.sessionIsNotReachable(minimumReachability: .backgroundOnly, actual: .notReachable)))
            return nil
        }
        let transfer = session.transferUserInfo(guaranteedMessage.jsonRepresentation())
        sessionDelegate.guaranteedMessageTransferCompletionHandlers[transfer] = completion
        return transfer
    }
    
    /// Transfers a Blob to the counterpart app.
    /// Blobs are better suited for sending large amounts of data.
    /// The system will continue to send this data after the sending device exits if
    /// necessary.
    ///
    /// The system can throttle Blob transfers if needed, so transfer speeds
    /// are not guaranteed.
    ///
    /// The current reachability must not be .notReachable.
    ///
    /// This function returns a cancellable object that you can use to cancel the transfer before it is complete.
    ///
    /// - Parameter blob: The Blob to transfer.
    /// - Parameter completion: An optional handler that is called when the transfer completes or fails.
    @discardableResult
    public func transfer(_ blob: Blob, completion: Blob.Completion? = nil) -> Cancellable? {
        guard currentReachability != .notReachable  else {
            completion?(.failure(Error.sessionIsNotReachable(minimumReachability: .backgroundOnly, actual: .notReachable)))
            return nil
        }
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let urlString = documentsDirectory.appending("/blob.data")
        let fileURL = URL(fileURLWithPath: urlString)
        do {
            try blob.dataRepresentation().write(to: fileURL)
            let transfer = session.transferFile(fileURL, metadata: nil)
            sessionDelegate.blobTransferCompletionHandlers[transfer] = completion
            return transfer
        } catch {
            completion?(.failure(error))
            return nil
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
    /// The current reachability must not be .notReachable.
    ///
    /// - Parameter context: The Context to sync with the counterpart app.
    public func sync(_ context: Context) throws {
        guard currentReachability != .notReachable  else {
            throw Error.sessionIsNotReachable(minimumReachability: .backgroundOnly, actual: .notReachable)
        }
        try session.updateApplicationContext(context.content)
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
    /// You can query the remaining number of transfers available for the day by
    /// checking the currentWatchState property.
    ///
    /// The current reachability must not be .notReachable.
    ///
    /// This function returns a cancellable object that you can use to cancel the transfer before it is complete.
    ///
    /// - Parameter complicationInfo: The ComplicationInfo to transfer.
    /// - Parameter completion: An optional handler that is called when the transfer completes or fails. If the transfer succeeds, you are passed the number of updates remaining for today as an `Int`.
    @discardableResult
    public func transfer(_ complicationInfo: ComplicationInfo, completion: ComplicationInfo.Completion? = nil) -> Cancellable? {
        guard currentReachability != .notReachable  else {
            completion?(.failure(Error.sessionIsNotReachable(minimumReachability: .backgroundOnly, actual: .notReachable)))
            return nil
        }
        let transfer = session.transferCurrentComplicationUserInfo(complicationInfo.jsonRepresentation())
        sessionDelegate.complicationInfoTransferCompletionHandlers[transfer] = completion
        return transfer
    }
    
    #endif
    
}
