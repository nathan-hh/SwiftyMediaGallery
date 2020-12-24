//
//  UIviewExt.swift
//  SwiftyMediaGallery
//
//  Created by nati on 27/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit


extension UIView {

    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
    }

    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
    
    func tap(numberOfTapsRequired: Int = 1, action: Action) {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: action,  action: #selector(action.action))
        tapRecognizer.numberOfTapsRequired = numberOfTapsRequired
        addGestureRecognizer(tapRecognizer)
    }
        
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    public var width: CGFloat {
        get {
            return size.width
        }
        set (newWidth) {
            var frame = self.frame
            frame.size.width = newWidth
            self.frame = frame
        }
    }
    
    public var height: CGFloat {
        get {
            return size.height
        }
        set (newHeight) {
            var frame = self.frame
            frame.size.height = newHeight
            self.frame = frame
        }
    }
    
    public var size: CGSize {
        get {
            return self.frame.size
        }
        set (newSize) {
            self.frame.size = newSize
        }
    }

    func rounded(cornerRadius : CGFloat? = nil)
    {
        self.layoutIfNeeded()
        self.layer.cornerRadius = cornerRadius ?? (height / 2)
        self.layer.masksToBounds = true;
        self.clipsToBounds = true;
    }
    
    func add(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }

    var recursiveSubviews: [UIView] {
        return subviews + subviews.flatMap { $0.recursiveSubviews }
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
