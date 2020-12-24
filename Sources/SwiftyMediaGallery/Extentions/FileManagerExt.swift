//
//  FileManagerEXT.swift
//  SwiftyMediaGallery
//
//  Created by nati on 03/10/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation

extension FileManager{
    public func sizeOfDirectory(at directoryURL: URL) throws -> Int64 {
        var enumeratorError: Error? = nil
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!

        var accumulatedSize: Int64 = 0
        for item in enumerator {
            if enumeratorError != nil { break }
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.localFileSize()
        }
        if let error = enumeratorError { throw error }
        return accumulatedSize
    }
}

fileprivate let allocatedSizeResourceKeys: Set<URLResourceKey> = [
    .isRegularFileKey,
    .fileAllocatedSizeKey,
    .totalFileAllocatedSizeKey,
]

fileprivate extension URL {
    func localFileSize() throws -> Int64 {
        let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }
        return Int64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }
}
