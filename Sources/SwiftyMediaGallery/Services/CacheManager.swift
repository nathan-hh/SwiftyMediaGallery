//
//  CacheManager.swift
//  SwiftyMediaGallery
//
//  Created by nati  on 27/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

protocol Cachable {
    associatedtype CacheType
    static func decode(data:Data) -> CacheType?
    func encode() -> Data?
}

struct Options: OptionSet {
    static let saveToDisk = Options(rawValue: 1 << 0)
    static let saveToMemory = Options(rawValue: 1 << 1)
    static let clearOnMemoryWarning = Options(rawValue: 1 << 2)
    static let all = [Options.saveToDisk, Options.saveToMemory, Options.clearOnMemoryWarning]

    let rawValue: Int
}

struct SharedCache {
    static let imageCache = CacheManager<URL,UIImage>(options: GalleryConfiguration.shared.cacheOptions)
}

var diskCacheCapacity :Int64{
    return (try? FileManager.default.sizeOfDirectory(at: cacheFolderURL)) ?? 0
}

var cacheFolderURL : URL =  {
    let folderURLs = FileManager.default.urls(for:.cachesDirectory,in: .userDomainMask)
    return folderURLs.first!
}()

final class CacheManager<Key: Hashable, Value:Cachable> {
    private let memoryCache = NSCache<WrappedKey, Entry>()
    private let maxDiskCache: Int64
    private let keyTracker = KeyTracker()
    private let options : Options
    private var memoryWarningObserver : NSObjectProtocol?
    var diskControlInterval: TimeInterval = 15

    private let capacityQueue = DispatchQueue(label: "com.gallery.capacityQueue", target: .global(qos: .utility))
    private let cacheQueue = DispatchQueue(label: "com.gallery.cacheQueue", attributes: .concurrent, target: .global(qos: .userInitiated))

    init(maxDiskCache :Int64 = Int64(GalleryConfiguration.shared._maxDiskCacheMB),options :Options) {
        self.maxDiskCache = maxDiskCache
        memoryCache.delegate = keyTracker
        self.options = options
        if options.contains(.clearOnMemoryWarning){
            clearOnMemoryWarning()
        }
        scheduleDiskCacheCapacityControl()
    }
    
    private func clearOnMemoryWarning(){
        memoryWarningObserver = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { [unowned self] _ in
                self.memoryCache.removeAllObjects()
                print("cache didReceiveMemoryWarningNotification")
            }
        )
    }

    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(key: key, value: value)
        keyTracker.keys.insert(entry.key)
        if options.contains(.saveToMemory){
            memoryCache.setObject(entry, forKey: WrappedKey(entry.key))
        }
        if let self = self as? CacheManager<URL,UIImage>, options.contains(.saveToDisk) {
            self.saveToDisk(entry as! CacheManager<URL, UIImage>.Entry)
        }
    }

    func value(forKey key: Key) -> Value? {
        if let entry = memoryCache.object(forKey: WrappedKey(key))  {
            return entry.value
        }else if let self = self as? CacheManager<URL,UIImage>,
            let entry = self.getValueFromDisk(forKey:key as! URL) as? Entry
        {
            if options.contains(.saveToMemory){
                memoryCache.setObject(entry, forKey: WrappedKey(key))
            }
            return entry.value
        }
        return nil;
    }

    func removeValue(forKey key: Key) {
        memoryCache.removeObject(forKey: WrappedKey(key))
    }
    
    private func scheduleDiskCacheCapacityControl() {
        diskCacheCapacityControl()
        capacityQueue.asyncAfter(deadline: .now() + diskControlInterval) { [weak self] in
            self?.scheduleDiskCacheCapacityControl()
        }
    }
    
    private func diskCacheCapacityControl(){
        guard diskCacheCapacity > maxDiskCache else { return }
        
        let fileManager = FileManager.default
        guard let directoryContents = try? fileManager.contentsOfDirectory( at: cacheFolderURL, includingPropertiesForKeys: nil, options: []) else{return}
        let sortedByTimeCreated = directoryContents.sorted(by: {$0.loaclFileContentAccess?.compare($1.loaclFileContentAccess ?? Date.distantPast) == .orderedAscending })
        for file in sortedByTimeCreated{
            if  diskCacheCapacity >= maxDiskCache{
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(memoryWarningObserver as Any, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
}

private extension CacheManager {
    final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) { self.key = key }
        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }

    final class Entry {
        let key: Key
        let value: Value

        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys : AtomicSet = AtomicSet<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }
            keys.remove(entry.key)
        }
    }
}

extension CacheManager {
    subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            cacheQueue.async {
                guard let value = newValue else {
                    self.removeValue(forKey: key)
                    return
                }
                self.insert(value, forKey: key)
            }
        }
    }
}

private extension CacheManager where Key == URL{
    func saveToDisk(_ entry: Entry)
    {
        let id = entry.key.absoluteString + ".cache"
        let fileURL = cacheFolderURL.appendingPathComponent(URL(string:id)!.lastPathComponent)
        do {
            try entry.value.encode()?.write(to: fileURL, options: .atomicWrite)
        }
        catch(let err) {
            print(err.localizedDescription)
        }
    }
    
    func getValueFromDisk(forKey key: Key) -> Entry?{
        let id = key.absoluteString + ".cache"

        let fileURL = cacheFolderURL.appendingPathComponent(URL(string:id)!.lastPathComponent)
        if let data = try? Data(contentsOf:fileURL, options: Data.ReadingOptions()), let val = Value.decode(data: data) as? Value  {
            return Entry(key: key, value: val)
        }
        return nil
    }
}
