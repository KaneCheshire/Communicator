//
//  ComplicationInfo.swift
//  Communicator
//
//  Created by Kane Cheshire on 20/07/2017.
//
//

import Foundation

/// Represents information to update complications in watchOS apps.
public struct ComplicationInfo {
    
    enum ErrorType: Error {
        case notAComplicationInfo
    }

    // MARK: - Properties -
    // MARK: Public
    
    /// The content of the ComplicationInfo as a JSON dictionary.
    public let content: JSONDictionary
    
    // MARK: - Initialisers -
    // MARK: Public
    
    /// Creates a new ComplicationInfo configured with some content.
    /// The content must be a JSON dictionary containing primitive plist types
    /// such as Strings, Ints, Data etc.
    ///
    /// - Parameter content: The content of the ComplicationInfo as a JSON dictionary.
    public init(content: JSONDictionary) {
        self.content = content
    }
    
    // MARK: Internal
    
    init(jsonDictionary: JSONDictionary) throws {
        guard let content = jsonDictionary["_ComplicationInfo"] as? JSONDictionary else {
            throw ErrorType.notAComplicationInfo
        }
        self.content = content
    }
    
    // MARK: - Functions -
    // MARK: Internal
    
    func jsonRepresentation() -> JSONDictionary {
        return ["_ComplicationInfo" : content]
    }
    
}
