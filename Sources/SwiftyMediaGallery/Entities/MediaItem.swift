//
//  MediaItem.swift
//  SwiftyMediaGallery
//
//  Created by nati on 14/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

public enum MediaType{
    case image
    case video
}

public protocol MediaItem{
    var type : MediaType {get}
    var url : String? {get}
    var thumbUrl : String? {get}
    var id : String? {get}
}

typealias ItemAction = (AnyMediaItem) -> Void

protocol MediaAction {
    static var _deleteClosure: ItemAction? {get}
    static var _shareClosure: ItemAction? {get}
    func onDelete(clusore: @escaping ItemAction)
    func onShare(clusore: @escaping ItemAction)
}

extension MediaItem {
    public var id: String?{
        var hasher = Hasher()
        hasher.combine(url)
        hasher.combine(thumbUrl)
        return String(hasher.finalize())
    }
}

public struct AnyMediaItem: MediaItem,Hashable{
    public var type: MediaType
    public var url: String?
    public var thumbUrl: String?
    public var id: String?

    public init<I>(_ item: I) where I : MediaItem {
        url = item.url
        thumbUrl = item.thumbUrl
        type = item.type
        id = item.id
    }
    
    public static func == (lhs: AnyMediaItem, rhs: AnyMediaItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

public struct ImageMediaItem :MediaItem{
    public var url: String?
    public var thumbUrl: String?
    public init(url:String?,thumbUrl:String? = nil) {
        self.url = url
        self.thumbUrl = thumbUrl
    }
    public var type: MediaType{
        return .image
    }
}

public struct VideoMediaItem :MediaItem{
    public var url: String?
    public var thumbUrl: String?
    public init(url:String?,thumbUrl:String? = nil) {
        self.url = url
        self.thumbUrl = thumbUrl
    }

    public var type: MediaType{
        return .video
    }
}
