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
    
    /// The current `Reachability` of `Communicator`.
    /// The current reachability determines what type of communication can
    /// occur, i.e. immediate messaging or background messaging only.
    ///
    /// You can observe changes to the `Reachability` by calling `Reachability.observe {}`
    public var currentReachability: Reachability {
        return Reachability(session: session)
    }
    
    /// The current `State` of `Communicator`, i.e. active or inactive.
    /// After becoming active, can change when a user unpairs their
    /// watch or switch watches.
    ///
    /// Generally you will care more about the `currentReachability` rather than the state.
    ///
    /// You can observe changes to the `State` by calling `Communicator.State.observe {}`
    public var currentState: State {
        return State(session: session.activationState)
    }
    
    /// This can be queried for the latest `Context` that has been _received_ on this device.
    /// The `Context` may have empty content if no Context has been received from
    /// the counterpart.
    ///
    /// You can observe `Context` updates by calling `Context.observe {}`
    ///
    /// You can also query the most recently _sent_ context.
    public var mostRecentlyReceievedContext: Context {
        return Context(content: session.receivedApplicationContext)
    }
    
    /// This can be queried for the latest `Context` that has been _sent_ by this device.
    /// The Context may have empty content if no `Context` has been sent from this device.
    ///
    /// You can also query the most recently _received_ context.``
    public var mostRecentlySentContext: Context {
        return Context(content: session.applicationContext)
    }
    
    /// Whether the underlying session still has data to send you.
    /// This could be true if the underlying session still has pending `Blob`s, `GuaranteedMessage`s, `Context`s or `ComplicationInfo`s.
    public var hasPendingDataToBeReceived: Bool {
        return session.hasContentPending
    }
    
    #if os(iOS)
    
    /// Can be queried to return the current watch state, i.e. whether it's paired etc.
    ///
    /// You can observe changes to the `WatchState` by calling `WatchState.observe {}`
    public var currentWatchState: WatchState {
        return WatchState(session: session)
    }
    
    #endif
    
    #if os(watchOS)
    
    /// Can be queried to return the current watch state, i.e. whether it's paired etc.
    ///
    /// You can observe changes to the `WatchState` by calling `WatchState.observe {}`
    public var currentPhoneState: PhoneState {
        return PhoneState(session: session)
    }
    
    /// If set, `Communicator` will automatically end this task when all background data has finished being received.
    /// You _must_ set this from your `ExtensionDelegate` when you receive one from the system, `Communicator` cannot
    /// automaticdally detect them.
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
    /// If an error occurs after the `ImmediateMessage` transfer is attempted, the error handler
    /// will be called.
    /// Do not use `ImmediateMessage` for sending large amounts of data, transfer a `Blob` instead.
    ///
    /// The current reachability _must_ be `.mmediatelyReachable.`
    ///
    /// You can observe received `ImmediateMessage`s by calling `ImmediateMessage.observe {}`
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
    
    /// Sends an interactive message immediately. Interactive messages have a reply handler that must be executed on the receiving end.
    ///
    /// If an error occurs after the `InteractiveImmediateMessage` transfer is attempted, the error handler
    /// will be called.
    /// Do not use `InteractiveImmediateMessage` for sending large amounts of data, transfer a `Blob` instead.
    ///
    /// The current reachability _must_ be `.immediatelyReachable.`
    ///
    /// You can observe received `InteractiveImmediateMessage`s by calling `InteractiveImmediateMessage.observe {}`
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
    /// `GuaranteedMessages` do _not_ require the counterpart app to be immediately reachable, as the system sends them at an "opportune" time.
    /// `GuaranteedMessages` are queued and delivered to the counterpart in the order they were
    /// queued. This means that you may get a stream of these messages after your app is launched.
    ///
    /// Do not use `GuaranteedMessage` for sending large amounts of data, transfer a `Blob` instead.
    ///
    /// The current reachability _must not_ be `.notReachable.`
    ///
    /// This function returns a `Cancellable` object that you can use to cancel the transfer before it is complete.
    ///
    /// You can observe received `GuaranteedMessage`s by calling `GuaranteedMessage.observe {}`
    ///
    /// - Parameter guaranteedMessage: The `GuaranteedMessage` to queue and send to the counterpart app.
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
    
    /// Transfers a `Blob` to the counterpart app.
    /// `Blob`s are better suited for sending large amounts of data.
    /// The system will continue to send this data after the app on the sending device exits if
    /// necessary.
    ///
    /// The system can throttle `Blob` transfers if needed, so transfer speeds
    /// are not guaranteed.
    ///
    /// The current reachability _must not_ be `.notReachable.`
    ///
    /// This function returns a `Cancellable` object that you can use to cancel the transfer before it is complete.
    ///
    /// You can observe received `Blob`s by calling `Blob.observe {}`
    ///
    /// - Parameter blob: The `Blob` to transfer.
    /// - Parameter completion: An optional handler that is called when the transfer completes or fails.
    @discardableResult
    public func transfer(_ blob: Blob, completion: Blob.Completion? = nil) -> Cancellable? {
        guard currentReachability != .notReachable  else {
            completion?(.failure(Error.sessionIsNotReachable(minimumReachability: .backgroundOnly, actual: .notReachable)))
            return nil
        }
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let urlString = documentsDirectory.appending("/blob-\(blob.identifier).data")
        let fileURL = URL(fileURLWithPath: urlString)
        do {
            try blob.dataRepresentation().write(to: fileURL)
            let transfer = session.transferFile(fileURL, metadata: blob.metadata)
            sessionDelegate.blobTransferCompletionHandlers[transfer] = { result in
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("deleting \(fileURL.lastPathComponent) failed \(error.localizedDescription)")
                }
                completion?(result)
            }
            return transfer
        } catch {
            completion?(.failure(error))
            return nil
        }
    }
    
    /// Syncs a `Context` with the counterpart app. Contexts are lightweight and should _not_ be used for messaging
    /// or transferring large amounts of data.
    ///
    /// `Context`s are perfect for syncing things like preferences. You can query the latest `Context` at any time
    /// with the`mostRecentlyReceievedContext` and `mostRecentlySentContext` properties of the `shared`
    /// `Communicator` object in each app.
    ///
    /// If an error occurs before syncing the `Context`, this function will `throw` an error.
    ///
    /// The current reachability _must not_ be `.notReachable.`
    ///
    /// You can observe received `Context`s by calling `Context.observe {}`
    ///
    /// - Parameter context: The Context to sync with the counterpart app.
    public func sync(_ context: Context) throws {
        guard currentReachability != .notReachable  else {
            throw Error.sessionIsNotReachable(minimumReachability: .backgroundOnly, actual: .notReachable)
        }
        try session.updateApplicationContext(context.content)
    }
    
    #if os(iOS)
    
    /// Starts the transfer of a `ComplicationInfo` to the watchOS app.
    ///
    /// If the watchOS app is reachable and the per-day limit of sending `ComplicationInfo` has not been reached,
    /// this method wakes up your watchOS app in the background to process it.
    ///
    /// At least one complication must be added to the active watch face to be able to wake up your watchOS app in the background.
    ///
    /// If the daily limit for sending `ComplicationInfo` updates has been reached, the system queues the transfer
    /// and will deliver it when the app is next able to process it, or when the per-day count
    /// gets reset.
    ///
    /// You can query the remaining number of transfers available for the day by
    /// checking the `currentWatchState` property.
    ///
    /// The current reachability _must not_ be `.notReachable.`
    ///
    /// This function returns a `Cancellable` object that you can use to cancel the transfer before it is complete.
    ///
    /// You can observe received `ComplicationInfo`s by calling `ComplicationInfo.observe {}` anywhere in your watchOS app.
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
