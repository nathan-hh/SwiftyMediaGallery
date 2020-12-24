//
//  UIImage+Cache.swift
//  SwiftyMediaGallery
//
//  Created by nati on 14/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit

extension UIImageView {
    
    //inject requestedUrl property to UIImageView Obj
    static var _associatedUrl = "UIImageView.AssociatedUrl"
    var requestedUrl : URL?{
        get{
            if let url = objc_getAssociatedObject(self, &UIImageView._associatedUrl)  {
                return url as? URL
            }
            return nil
        }
        set{
            objc_setAssociatedObject(self, &UIImageView._associatedUrl, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    static var _actInd = "UIImageView.actInd"
    var actIndView :UIActivityIndicatorView {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if let object = objc_getAssociatedObject(self, &UIImageView._actInd), let act = object as? UIActivityIndicatorView  {
            return act
        }else{
            let act = UIActivityIndicatorView(style:.medium)
            act.hidesWhenStopped = true
            act.center = center
            add(act)
            objc_setAssociatedObject(self, &UIImageView._actInd,act, .OBJC_ASSOCIATION_RETAIN)
            return act
        }
    }
    
    public func set(image url: String?,withIndicator: Bool = true){
        guard let turl = url ,let imageURL = URL(string:turl) else {
            return
        }
        image = GalleryConfiguration.shared.imagePlaceholder
        requestedUrl = imageURL
        withIndicator ? actIndView.startAnimating() : ()
        Downloader.shared.downloadOrGetFromLocal(image: imageURL) {[weak self] (image) in
            if self?.requestedUrl == imageURL{
                DispatchQueue.main.async {[weak self]  in
                    self?.image = image
                    withIndicator ? self?.actIndView.stopAnimating() : ()
                }
            }else{

            }
        }
    }
    
    func transition(toImage image: UIImage){
        UIView.transition(with: self, duration:0.3, options: [.transitionCrossDissolve], animations: {
            self.image = image
        },
        completion: nil)
        self.image = image
    }
    
}
