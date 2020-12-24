//
//  GenerateThumbOperation.swift
//  SwiftyMediaGallery
//
//  Created by nati on 10/10/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

class GenerateThumbOperation: BaseOperation,AnyOperation{
    typealias Result = UIImage;

    init(url: URL, completionHandler:DownloadCompletion<Result>?) {
        super.init()
        self.url = url
        append(completionHandler: completionHandler)
    }
        
    override  func start() {
        if !isCancelled {
            url?.generateThumbFromVideo {[weak self] (image) in
                if let image = image{
                    self?.completeHandlers.forEach{$0?(image)}
                }
                self?.finish()
            }
        }
        super.start()
    }
}
