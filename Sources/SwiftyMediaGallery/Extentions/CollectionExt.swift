//
//  CollectionEXT.swift
//  SwiftyMediaGallery
//
//  Created by nati on 31/10/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
extension Collection where Element: Equatable {

    func subtracting(elements filter: [Element]) -> [Element] {
        return self.filter { element in !filter.contains(element) }
    }

}
