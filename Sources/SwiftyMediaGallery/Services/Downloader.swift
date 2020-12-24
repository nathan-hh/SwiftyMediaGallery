//
//  Downloader.swift
//  SwiftyMediaGallery
//
//  Created by nati on 29/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

typealias DownloadCompletion<Item> = (Item) -> Void

protocol PrefetcherProtocol {
    static func startFetching(urls:[URL])
    static func cancelFetching(urls:[URL])
}

struct Prefetcher:PrefetcherProtocol{

    static func startFetching(urls:[URL]) {
        urls.forEach { (url) in
            Downloader.shared.downloadOrGetFromLocal(image: url)
        }
    }
    
    static func cancelFetching(urls:[URL]) {
        urls.forEach { (url) in
            Downloader.shared.cancelTaskForUrl(image: url)
        }
    }
}

final class Downloader {
    static let shared = Downloader()
    private var loadingOperations = AtomicDictionary<URL,BaseOperation>()
    
    //synchronize tasks
    private let serialQueue = DispatchQueue(label: "com.gallery.DownloadPipeline",qos: .userInitiated, target: DispatchQueue.global(qos:.userInitiated))

    private init(){}

    let maxConcurrentOperationCount = 15
    private var lastOperations = [Operation](){
        didSet{
            if lastOperations.count > maxConcurrentOperationCount{
                lastOperations.removeFirst()
            }
        }
    }
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        queue.qualityOfService = .userInitiated
        queue.name = "downloader-queue"
        return queue
    }()
    
    func cancelTaskForUrl(image url: URL){
        let task = queue.operations.compactMap{$0 as? BaseOperation}.filter{$0.url == url}.first
        task?.cancel()
        loadingOperations[url] = nil
    }
    
    func downloadOrGetFromLocal(image url: URL, completion: DownloadCompletion<UIImage>? = nil){
        if url.isVideo{
            let operation = GenerateThumbOperation(url:url, completionHandler: { (image) in
                imageCompletion(image: image, useCache: true)
            })
            addTask(op: operation, for: url, completion: completion)
        }else{
            if url.isFileURL{
                let operation = GetLocalFileOperation(url:url, completionHandler: { (image) in
                    imageCompletion(image: image, useCache: false)
                })
                addTask(op: operation, for: url, completion: completion)
            }else{
                let operation = DownloadOperation(downloadTaskURL: url, completionHandler: { (image) in
                    imageCompletion(image: image, useCache: true)
                })
                addTask(op: operation, for: url, completion: completion)
            }
        }
        
        func imageCompletion(image:UIImage, useCache:Bool){
            let image = image.decompressed();
            SharedCache.imageCache[url] = image;
            completion?(image)
            self.loadingOperations[url] = nil
        }
    }
    
    private func addTask(op: Operation, for url:URL, completion: DownloadCompletion<UIImage>?){
        serialQueue.async { [weak self] in
            if let image = SharedCache.imageCache[url] {
                completion?(image)
                return
            }
            if let op = self?.loadingOperations[url] {
                op.append(completionHandler: completion)
                self?.lastOperations.append(op)
            }else{
                self?.loadingOperations[url] = op as? BaseOperation
                self?.queue.addOperation(op)
                self?.lastOperations.append(op)
            }
            
            self?.reprioritizeOperations()
        }
    }
    
    private func reprioritizeOperations(){
        let ops = queue.operations.subtracting(elements: lastOperations).compactMap{$0 as? BaseOperation}
        ops.forEach{$0.queuePriority = .veryLow}
        lastOperations.forEach{$0.queuePriority = .veryHigh}
    }
}
