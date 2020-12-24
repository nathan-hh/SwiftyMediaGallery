//
//  ZoomAnimator.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

final class ZoomAnimator: UIPercentDrivenInteractiveTransition {
    var to: ZoomAnimatorRreferences?
    var from: ZoomAnimatorRreferences?

    var transitionImageView: UIImageView?
    var isPresenting: Bool = true
    var presentingTransitionDuration:TimeInterval = 0.5
    var dismissingTransitionDuration:TimeInterval = 0.5

    fileprivate func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromReferenceImageView = self.from?.referenceImageView(),
            let toReferenceImageView = self.to?.referenceImageView(),
            let fromReferenceImageViewFrame = self.from?.referenceImageViewFrameInTransitioningView()
            else {
                return
        }
        
//        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
//        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        toVC.view.alpha = 0
        toReferenceImageView.isHidden = true
        containerView.addSubview(toVC.view)

        let referenceImage = fromReferenceImageView.image
        
        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
            containerView.insertSubview(transitionImageView, belowSubview: toVC.view)
        }
        
        fromReferenceImageView.isHidden = true
        
        let finalTransitionSize = calculateZoomInImageFrame(image: referenceImage, forView: toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [UIView.AnimationOptions.transitionCrossDissolve],
                       animations: {
                        self.transitionImageView?.frame = finalTransitionSize
                        fromVC.tabBarController?.tabBar.alpha = 0
                        toVC.view.alpha = 1.0

        },
                       completion: { completed in

                        self.transitionImageView?.removeFromSuperview()
                        let toReferenceImageView = self.to?.referenceImageView()

                        toReferenceImageView?.isHidden = false
                        fromReferenceImageView.isHidden = false
                        
                        self.transitionImageView = nil
                        
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//                        self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
//                        self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
        })
    }
    
    fileprivate func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromReferenceImageView = self.from?.referenceImageView(),
            let toReferenceImageView = self.to?.referenceImageView(),
            let fromReferenceImageViewFrame = self.from?.referenceImageViewFrameInTransitioningView(),
            let toReferenceImageViewFrame = self.to?.referenceImageViewFrameInTransitioningView()
            else {
                return
        }
//        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
//        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        toReferenceImageView.isHidden = true
        
        let referenceImage = fromReferenceImageView.image
        
        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        fromReferenceImageView.isHidden = true
        
        let finalTransitionSize = toReferenceImageViewFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [],
                       animations: {
                        fromVC.view.alpha = 0
                        self.transitionImageView?.frame = finalTransitionSize
                        toVC.tabBarController?.tabBar.alpha = 1
        }, completion: { completed in
            
            self.transitionImageView?.removeFromSuperview()
            toReferenceImageView.isHidden = false
            fromReferenceImageView.isHidden = false
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
//            self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
        })
    }
    
    private func calculateZoomInImageFrame(image: UIImage?, forView view: UIView) -> CGRect {
        guard let image = image else {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        let viewRatio = view.frame.size.width / view.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let touchesSides = (imageRatio > viewRatio)
        
        if touchesSides {
            let height = view.frame.width / imageRatio
            let yPoint = view.frame.minY + (view.frame.height - height) / 2
            return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        } else {
            let width = view.frame.height * imageRatio
            let xPoint = view.frame.minX + (view.frame.width - width) / 2
            return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
        }
    }
}

extension ZoomAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isPresenting {
            return presentingTransitionDuration
        } else {
            return dismissingTransitionDuration
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}
