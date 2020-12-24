//
//  MediaControllerViewModel.swift
//  SwiftyMediaGallery
//
//  Created by nati on 14/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class MediaControllerViewModel {
    var arrMediaItems = CurrentValueSubject <[AnyMediaItem], Never>([AnyMediaItem]())
    
    convenience init(arrMediaItems : CurrentValueSubject<[AnyMediaItem],Never>) {
        self.init()
        self.arrMediaItems = arrMediaItems
    }
    
    func deleteMedia(idx:IndexPath){
        GalleryConfiguration._deleteClosure?(arrMediaItems.value[idx.row])
        arrMediaItems.value.remove(at: idx.row)
    }
    
    func shareMedia(idx:IndexPath){
        GalleryConfiguration._shareClosure?(arrMediaItems.value[idx.row])
    }
    
    func prefetchItemsAt(indexPaths:[IndexPath]){
        let urls = getFetchingUrls(indexPaths: indexPaths);
 //       Prefetcher.startFetching(urls: urls)
    }
    
    func cancelPrefetching(indexPaths:[IndexPath]){
        let urls = getFetchingUrls(indexPaths: indexPaths);
      //  Prefetcher.cancelFetching(urls: urls)
    }
    
    private func getFetchingUrls(indexPaths:[IndexPath]) -> [URL]{
        let slice = Array(indexPaths.map{$0.row})
        guard let first = slice.first , let last = slice.last else { return [URL]()}
        let fetchingRange = first < last ? (first...last) :  (last...first)
        let items = arrMediaItems.value[fetchingRange]
        return items.compactMap { URL(string: $0.url!)}
    }
    
    func getMediaItem(idx:IndexPath) -> AnyMediaItem{
        return arrMediaItems.value[idx.item]
    }
}
