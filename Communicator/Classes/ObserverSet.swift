//
//  ObserverSet.swift
//  Communicator
//
//  Created by Kane Cheshire on 19/07/2017.
//
//

import Foundation

// TODO: Add TABObserverSet as a dependency when it supports watchOS in the podspec

/*
 ObserverSet is distributed under a BSD license, as listed below.
 
 Copyright (c) 2015, Michael Ash
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 Neither the name of Michael Ash nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Modified by Kane Cheshire on 21 February 2017

import Dispatch

/// A reference to an entry in the list of observers. Use this to remove an observer.
open class ObserverSetEntry<Parameters> {
    
    fileprivate weak var observer: AnyObject?
    fileprivate let callBack: (Any) -> (Parameters) -> Void
    
    fileprivate init(observer: AnyObject?, callBack: @escaping (Any) -> (Parameters) -> Void) {
        self.observer = observer
        self.callBack = callBack
    }
    
}

/// A set of observers that can be notified of certain actions. A more Swift-like version of NSNotificationCenter.
open class ObserverSet<Parameters> {
    
    // MARK: - Private properties
    
    private var entries: [ObserverSetEntry<Parameters>] = []
    
    // MARK: - Initialisers
    
    /**
     Creates a new instance of an observer set.
     
     - returns: A new instance of an observer set.
     */
    public init() {}
    
    // MARK: - Public functions
    
    /**
     Adds a new observer to the set.
     
     - parameter observer: The object that is to be notified.
     - parameter callBack: The function to call on the observer when the notification is to be delivered.
     
     - returns: An entry in the list of observers, which can be used later to remove the observer.
     */
    @discardableResult
    open func add<ObserverType: AnyObject>(_ observer: ObserverType,  _ callBack: @escaping (ObserverType) -> (Parameters) -> Void) -> ObserverSetEntry<Parameters> {
        let entry = ObserverSetEntry<Parameters>(observer: observer) { observer in callBack(observer as! ObserverType) }
        synchronized {
            self.entries.append(entry)
        }
        return entry
    }
    
    /**
     Adds a new function to the list of functions to invoke when a notification is to be delivered.
     
     - parameter callBack: The function to call when the notification is to be delivered.
     
     - returns: An entry in the list of observers, which can be used later to remove the observer.
     */
    @discardableResult
    open func add(_ callBack: @escaping (Parameters) -> Void) -> ObserverSetEntry<Parameters> {
        return self.add(self) { ignored in callBack }
    }
    
    /**
     Removes an observer from the list, using the entry which was returned when adding.
     
     - parameter entry: An entry returned when adding a new observer.
     */
    open func remove(_ entry: ObserverSetEntry<Parameters>) {
        synchronized {
            self.entries = self.entries.filter{ $0 !== entry }
        }
    }
    
    /**
     Call this method to notify all observers.
     
     - parameter parameters: The parameters that are required parameters specified using generics when the instance is created.
     */
    
    open func notify(_ parameters: Parameters) {
        
        var callBackList: [(Parameters) -> Void] = []
        
        synchronized {
            for entry in self.entries {
                if let observer = entry.observer {
                    callBackList.append(entry.callBack(observer))
                }
            }
            self.entries = self.entries.filter{ $0.observer != nil }
        }
        for callBack in callBackList {
            callBack(parameters)
        }
    }
    
    // MARK: - Private functions
    // MARK: Locking support
    
    private var queue = DispatchQueue(label: "com.theappbusiness.ObserverSet", attributes: [])
    
    private func synchronized(_ f: (Void) -> Void) {
        queue.sync(execute: f)
    }
    
}
