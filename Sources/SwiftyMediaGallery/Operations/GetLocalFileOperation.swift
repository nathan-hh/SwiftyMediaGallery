//
//  GetLocalFileOperation.swift
//  SwiftyMediaGallery
//
//  Created by nati on 10/10/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit
class GetLocalFileOperation: BaseOperation,AnyOperation{
    typealias Result = UIImage;

    init(url: URL, completionHandler:DownloadCompletion<Result>?) {
        super.init()
        self.url = url
        append(completionHandler: completionHandler)
    }
        
    override func start() {
        if !isCancelled {
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf:self.url!,options:Data.ReadingOptions()),let image = UIImage.decode(data: data){
                    self.completeHandlers.forEach{$0?(image)}
                }
                self.finish()
            }
        }
        super.start()
    }
}
