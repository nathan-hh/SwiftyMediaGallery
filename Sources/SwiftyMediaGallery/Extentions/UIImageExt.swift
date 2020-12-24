//
//  UIImageEXT.swift
//  SwiftyMediaGallery
//
//  Created by nati on 03/09/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import MobileCoreServices

extension UIImage{
    func toProgressive(fileName: String) -> URL{
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let targetUrl = documentsUrl.appendingPathComponent("fileName" + ".jpg") as CFURL

        let destination = CGImageDestinationCreateWithURL(targetUrl, kUTTypeJPEG, 1, nil)!
        let jfifProperties = [kCGImagePropertyJFIFIsProgressive: kCFBooleanTrue as Any] as NSDictionary
        let properties = [
            kCGImageDestinationLossyCompressionQuality: 0.6,
            kCGImagePropertyJFIFDictionary: jfifProperties
        ] as NSDictionary

        CGImageDestinationAddImage(destination, self.cgImage!, properties)
        CGImageDestinationFinalize(destination)
        return targetUrl as URL
    }
    
    func decompressed() -> UIImage {
        guard let cgImage = cgImage else { return self }
        let maxSize = GalleryConfiguration.shared.imageRendererMaxSize
        let size = sized(targetSize: maxSize)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return UIImage(cgImage: decodedImage)
    }

    func scaled(to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { (_) in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func sized(targetSize:CGSize) -> CGSize {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        return CGSize(width: newSize.width, height: newSize.height)
    }

}

let compressionQuality : CGFloat = 0.6
let lock = NSLock()

extension UIImage: Cachable {
    typealias CacheType = UIImage
    static func decode(data:Data) -> CacheType? {
        defer {lock.unlock() }
        lock.lock()
        return UIImage(data: data, scale:UIScreen.main.scale)
    }
    func encode() -> Data? {
        return jpegData(compressionQuality: compressionQuality)
    }
    
//    func encode() -> Data? {
//        let data = NSMutableData()
//        let options: NSDictionary = [
//            kCGImageDestinationLossyCompressionQuality: compressionQuality
//        ]
//        guard let source = cgImage,
//            let destination = CGImageDestinationCreateWithData(
//                data as CFMutableData, "public.jpeg" as CFString, 1, nil
//            ) else {
//                return nil
//        }
//        CGImageDestinationAddImage(destination, source, options)
//        CGImageDestinationFinalize(destination)
//        return data as Data
//    }
}

extension UIImage:Sizeable{
    var fileSizeBytes : Int64{
        return Int64(encode()?.count ?? 0)
    }
}
