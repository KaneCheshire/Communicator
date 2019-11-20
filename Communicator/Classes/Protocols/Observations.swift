//
//  Observations.swift
//  Pods
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

public struct Observation: Hashable {
    
    let uuid = UUID()
    let queue: DispatchQueue
    
}

public struct Observations<H> {
    
    var store: [Observation: H] = [:]
    
}

public protocol Observable {
    
    static var observations: Observations<(Self) -> Void> { get set }
    
}

public extension Observable {
    
    @discardableResult
    static func observe(queue: DispatchQueue = .communicator, handler: @escaping (Self) -> Void) -> Observation {
        let observeration = Observation(queue: queue)
        observations.store[observeration] = handler
        return observeration
    }
    
    static func unobserve(_ observeration: Observation) {
        observations.store[observeration] = nil
    }
    
}

extension Observable {
    
    static func notifyObservers(_ object: Self) {
        observations.store.forEach { observation in
            observation.key.queue.async {
                observation.value(object)
            }
        }
    }
    
}

extension GuaranteedMessage: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

extension Blob: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

extension ImmediateMessage: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

extension InteractiveImmediateMessage: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

extension Context: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

extension Reachability: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

extension Communicator.State: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

#if os(iOS)

extension WatchState: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

#endif

#if os(watchOS)

extension ComplicationInfo: Observable {
    
    public static var observations: Observations<(Self) -> Void>  = .init()
    
}

#endif
