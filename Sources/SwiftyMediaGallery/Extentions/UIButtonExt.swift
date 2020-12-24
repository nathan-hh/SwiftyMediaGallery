//
//  UIButtonEXT.swift
//  SwiftyMediaGallery
//
//  Created by nati on 03/09/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit

final class Action: NSObject {
    private let _action: () -> ()
    init(action: @escaping () -> ()) {
        _action = action
        super.init()
    }
    @objc func action() {
        _action()
    }
}

extension UIButton{
    
    func onClick(action: Action,shouldSelect:Bool = false, image:UIImage? = nil) {
        addTarget(self, action: #selector(action.action), for: UIControl.Event.touchUpInside)
        setImage(image, for:.selected)
    }
}

