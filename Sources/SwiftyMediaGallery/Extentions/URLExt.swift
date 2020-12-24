//
//  URLExt.swift
//  SwiftyMediaGallery
//
//  Created by nati on 28/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol Sizeable {
    var fileSizeBytes: Int64 {get}
}

extension Sizeable{
    var fileSize : String {
        return ByteCountFormatter.string(fromByteCount: fileSizeBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }

    var fileSizeKB: Int64 {
        return fileSizeBytes / 1024
    }
    
    var fileSizeMB: Int64 {
        return fileSizeKB / 1024
    }
}

extension URL{
    var attributes: [FileAttributeKey : Any]? {
        return try? FileManager.default.attributesOfItem(atPath: path)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
    
    public var isImage : Bool {
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        if let ext = getExtension {
            return imageFormats.contains(ext.lowercased())
        }
        return false
    }
    
    public var isVideo : Bool {
        let videoFormats = ["mp4", "mov"]
        if let ext = getExtension {
            return videoFormats.contains(ext.lowercased())
        }
        return false
    }

    var getExtension: String? {
        let ext = (absoluteString as NSString).pathExtension
        if ext.isEmpty {
            return nil
        }
        return ext
    }
    
    var loaclFileContentAccess:Date?{
        return try? resourceValues(forKeys:[.contentAccessDateKey]).contentAccessDate
    }
    
    func generateThumbFromVideo( completion: @escaping (_ image: UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: self)
               let imageGenerator = AVAssetImageGenerator(asset: asset)
               imageGenerator.appliesPreferredTrackTransform = true
            do {
                let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
                completion(UIImage(cgImage: cgImage))
            } catch {
                completion(nil)
                print("generateThumb " + error.localizedDescription)
            }
        }
    }
}

extension URL:Sizeable{
    var fileSizeBytes: Int64 {
        if isFileURL{
            return loaclFileSizeBytes
        }
        return Int64((try? self.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
    }
    
    private var loaclFileSizeBytes:Int64{
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: self.path)
        return fileAttributes?[FileAttributeKey.size] as? Int64 ?? 0
    }
}

