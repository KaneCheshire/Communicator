//
//  InteractiveImmediateMessage.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

/// <#Description#>
public struct InteractiveImmediateMessage {
    
    public typealias Reply = (Content) -> Void
    public typealias ErrorHandler = (Error) -> Void
    
    /// <#Description#>
    public let identifier: String
    /// <#Description#>
    public let content: Content
    /// <#Description#>
    public let reply: Reply
    
    /// <#Description#>
    /// - Parameters:
    ///   - identifier: <#identifier description#>
    ///   - content: <#content description#>
    ///   - reply: <#reply description#>
    public init(identifier: String, content: Content, reply: @escaping Reply) { // TODO: Can content default to an empty value?
        self.identifier = identifier
        self.content = content
        self.reply = reply
    }
    
}

extension InteractiveImmediateMessage {
    
    init?(content: Content, reply: @escaping Reply) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Content else { return nil }
        self.init(identifier: identifier, content: content, reply: reply)
    }
    
}

extension InteractiveImmediateMessage: ContentPackagable {}
