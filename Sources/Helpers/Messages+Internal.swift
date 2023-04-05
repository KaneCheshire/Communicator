//
//  Messages+Internal.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

extension Blob {
    
    init?(content: Content, metadata: Content?) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Data else { return nil }
        self.init(identifier: identifier, content: content, metadata: metadata)
    }
    
    func dataRepresentation() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: ["identifier" : identifier,
                                                             "content" : content] as [String: Any])
    }
    
}

extension ComplicationInfo {
    
    init?(jsonDictionary: Content) {
        guard let content = jsonDictionary["__complication_info__"] as? Content else { return nil }
        self.content = content
    }
    
    func jsonRepresentation() -> Content {
        return ["__complication_info__" : content]
    }
    
}

extension GuaranteedMessage {
    
    init?(content: Content) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Content else { return nil }
        self.init(identifier: identifier, content: content)
    }
    
}

extension GuaranteedMessage: ContentPackagable {}

extension ImmediateMessage {
    
    init?(content: Content) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Content else { return nil }
        self.init(identifier: identifier, content: content)
    }
    
}

extension ImmediateMessage: ContentPackagable {}

extension InteractiveImmediateMessage {
    
    init?(content: Content, reply: @escaping Reply) {
        guard let identifier = content["identifier"] as? String else { return nil }
        guard let content = content["content"] as? Content else { return nil }
        self.init(identifier: identifier, content: content, reply: reply)
    }
    
}

extension InteractiveImmediateMessage: ContentPackagable {}
