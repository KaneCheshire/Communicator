//
//  Reachability.swift
//  Pods
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

/// Represents the current reachability of the counteroart app..
///
/// - notReachable: The counterpart app is not reachable at all.
/// - backgroundOnly: The counterpart app is reachable but only for background messaging types. (i.e Blobs, GuaranteedMessages, Contexts and ComplicationInfos)
/// - immediatelyReachable: The counterpart app is available for all types of messaging.
public enum Reachability {
    case notReachable
    case backgroundOnly
    case immediatelyReachable
}
