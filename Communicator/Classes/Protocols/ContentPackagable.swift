//
//  ContentPackagable.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

public typealias Content = [String : Any]

protocol ContentPackagable {
    
    var identifier: String { get }
    var content: Content { get }
    
}

extension ContentPackagable {
    
    func jsonRepresentation() -> Content {
           return ["identifier" : identifier,
                   "content" : content]
       }
    
}
