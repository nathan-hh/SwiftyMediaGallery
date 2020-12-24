//
//  Configuration.swift
//  SwiftyMediaGallery
//
//  Created by nati on 23/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

public final class GalleryConfiguration  {
    public static let shared = GalleryConfiguration()
    var _maxDiskCacheMB : Int64 = 200

    private init(){
        diskCacheMB = 200
    }

    public var title = "Media Gallery"
    public var backgroundColor : UIColor = .backgroundGray
    var sliderBackgroundColor : UIColor?
    public var videoPlaceholder :UIImage? = nil
    public var imagePlaceholder :UIImage? = nil
    public var diskCacheMB : Int64{
        get{
            return diskCacheCapacity / 1024 / 1024
        }
        set{
            _maxDiskCacheMB = newValue * 1024 * 1024
        }
    }
    var cacheOptions : Options = [.clearOnMemoryWarning,.saveToDisk,.saveToMemory]
    public var imageRendererMaxSize = CGSize(width: 1200,height: 1200)

}

extension GalleryConfiguration: MediaAction{
    static var _deleteClosure: ItemAction?
    static var _shareClosure: ItemAction?
    public func onDelete(clusore: @escaping (AnyMediaItem) -> Void) {
        GalleryConfiguration._deleteClosure = clusore
    }
    
    public func onShare(clusore: @escaping (AnyMediaItem) -> Void) {
        GalleryConfiguration._shareClosure = clusore
    }
}
