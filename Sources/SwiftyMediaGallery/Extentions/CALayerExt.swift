//
//  CALayerEXT.swift
//  SwiftyMediaGallery
//
//  Created by nati on 28/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {

   func bringToFront() {
      guard let sLayer = superlayer else {
         return
      }
      removeFromSuperlayer()
      sLayer.insertSublayer(self, at: UInt32(sLayer.sublayers?.count ?? 0))
   }

   func sendToBack() {
      guard let sLayer = superlayer else {
         return
      }
      removeFromSuperlayer()
      sLayer.insertSublayer(self, at: 0)
   }
}
