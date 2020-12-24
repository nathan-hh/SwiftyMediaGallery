//
//  DownloadOperation.swift
//  SwiftyMediaGallery
//
//  Created by nati on 10/10/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

class DownloadOperation: BaseOperation,AnyOperation{
    private var task : URLSessionTask!
    typealias Result = UIImage;

    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity:0)
        return URLSession(configuration: configuration,delegate: nil,delegateQueue: nil)
    }()
    
    init(downloadTaskURL: URL, completionHandler:DownloadCompletion<Result>?) {
        super.init()
        self.url = downloadTaskURL
        append(completionHandler: completionHandler)
        task = downloadsSession.dataTask(with: downloadTaskURL, completionHandler: {[weak self] (data, response, err) in
            if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300 {
                if let image = UIImage(data: data, scale:UIScreen.main.scale){
                    self?.completeHandlers.forEach{$0?(image)}
                    self?.finish()
                }
            }else{
                self?.finish()
            }
        })
    }
    
    override  func start() {
        if !isCancelled {
            self.task.resume()
        }
        super.start()
    }
    
    override func suspend() {
        self.task.suspend()
        super.suspend()
    }
    
    override func cancel() {
        self.task.cancel()
        super.cancel()
    }
}

extension DownloadOperation: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    }
}
