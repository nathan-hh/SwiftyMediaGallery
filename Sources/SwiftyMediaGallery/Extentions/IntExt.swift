//
//  IntEXT.swift
//  SwiftyMediaGallery
//
//  Created by nati on 28/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation

extension Int
{
    var localizedSecondsTime : String {
        return String(format: "%0.2d:%0.2d",
                      arguments: [(self / 60) % 60, (self % 60 ) ])
    }
}
