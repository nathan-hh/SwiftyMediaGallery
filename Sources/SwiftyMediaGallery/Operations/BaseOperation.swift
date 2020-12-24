//
//  BaseOperation.swift
//  SwiftyMediaGallery
//
//  Created by nati on 15/09/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

protocol AnyOperation {
    associatedtype Result
}

class BaseOperation: Foundation.Operation {
    internal var completeHandlers = [DownloadCompletion<UIImage>?]()
    internal var lock = NSLock()
    var url = URL(string: "")
        
    @objc enum OperationState : Int {
        case ready
        case executing
        case finished
    }
    
    override var isReady:        Bool { return state == .ready && super.isReady }
    final override var isExecuting:    Bool { return state == .executing }
    final override var isFinished:     Bool { return state == .finished }
    final override var isAsynchronous: Bool { return true }
    private var _state : OperationState = .ready

    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    @objc dynamic var state: OperationState {
        get {
            defer{lock.unlock()}; lock.lock()
            return _state
        }
        set {
            defer{lock.unlock()}; lock.lock()
            self._state = newValue
        }
    }
    
    override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }
        state = .executing
    }
    
    public final func finish() {
        if !isFinished { state = .finished }
    }
    
    func append(completionHandler: DownloadCompletion<UIImage>?){
        queuePriority = .veryHigh
        completeHandlers.append(completionHandler)
    }

    override func cancel() {
        super.cancel()
    }
    
    func suspend() { }
}
