//
//  DispatchQueue+Communicator.swift
//  Communicator-iOS
//
//  Created by Kane Cheshire on 20/11/2019.
//

import Foundation

public extension DispatchQueue {
    
    static let communicator = DispatchQueue(label: "com.kanecheshire.Communicator", qos: .userInteractive)
}

