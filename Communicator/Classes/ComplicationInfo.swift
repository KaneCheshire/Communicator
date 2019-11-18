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
    
    public typealias Completion = (Result<Void, Swift.Error>) -> Void
    
    enum ErrorType: Error {
        case notAComplicationInfo
    }

    // MARK: - Properties -
    // MARK: Public
    
    /// The content of the ComplicationInfo as a JSON dictionary.
    public let content: Content
    
    // MARK: - Initialisers -
    // MARK: Public
    
    /// Creates a new ComplicationInfo configured with some content.
    /// The content must be a JSON dictionary containing primitive plist types
    /// such as Strings, Ints, Data etc.
    ///
    /// - Parameter content: The content of the ComplicationInfo as a JSON dictionary.
    public init(content: Content) {
        self.content = content
    }
    
    // MARK: Internal
    
    init(jsonDictionary: Content) throws {
        guard let content = jsonDictionary["_ComplicationInfo"] as? Content else {
            throw ErrorType.notAComplicationInfo
        }
        self.content = content
    }
    
    // MARK: - Functions -
    // MARK: Internal
    
    func jsonRepresentation() -> Content {
        return ["_ComplicationInfo" : content]
    }
    
}
