//
//  AtomicSet.swift
//  SwiftyMediaGallery
//
//  Created by nati on 03/10/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
final class AtomicSet<Element> where Element :Hashable{
    private var _set: Set<Element> = Set<Element>()
    let lock = NSLock();

    public func contains(_ member : Element)  -> Bool{
        defer{lock.unlock()}; lock.lock()
        return _set.contains(member)
    }
    
    public func insert(_ newMember: Element){
        defer{lock.unlock()}; lock.lock()
        _set.insert(newMember)
    }

    public func update(with newMember: Element) {
        defer{lock.unlock()}; lock.lock()
        _set.update(with: newMember)
    }

    public func remove(_ member: Element){
        defer{lock.unlock()}; lock.lock()
        _set.remove(member)
    }
}

final class AtomicDictionary<KeyType:Hashable,ValueType>
{
    private var _dictionary:Dictionary<KeyType,ValueType> = [:]
    let lock = NSLock();
    
    subscript(key: KeyType) -> ValueType? {
        get {
        var value : ValueType?
            defer{lock.unlock()}; lock.lock()
            value = self._dictionary[key]
            return value
        }
        set {
            setValue(value: newValue, forKey: key)
        }
    }
  
    private func setValue(value: ValueType?, forKey key: KeyType) {
        defer{ lock.unlock() } ; lock.lock()
        _dictionary[key] = value
    }
}
