//
//  ImagePreviewTransitionDelegate.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/7/8.
//

import UIKit


public class ImagePreviewTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private var isPresented = true
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresented = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresented = false
        return self
    }
    

    
}


extension ImagePreviewTransitionDelegate: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresented {
            animationForPresented(using: transitionContext)
        } else {
            animationForDissmissed(using: transitionContext)
        }
        
    }
    
    func animationForPresented(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.view(forKey: .to)!
        transitionContext.containerView.addSubview(toView)
        let toController = transitionContext.viewController(forKey: .to) as! ImagePreviewController
        let originalView = toController.delegate.photo(of: toController.selectedIndex, with: toController).originalView
        guard originalView != nil else {
            transitionContext.completeTransition(true)
            return
        }
        
        let blackView = UIView.init(frame: UIScreen.main.bounds)
        blackView.backgroundColor = UIColor.black
        transitionContext.containerView.addSubview(blackView)
        let newRect = originalView!.convert(originalView!.bounds, to: nil)
        let imageView = UIImageView.init(frame: newRect)
        imageView.image = originalView?.image!
        imageView.contentMode = originalView!.contentMode
        transitionContext.containerView.addSubview(imageView)
        
        UIView.animate(withDuration: toController.presentDuration, animations: {
            
            imageView.frame = UIScreen.main.bounds
            imageView.contentMode = .scaleAspectFit
            
        }) { (finish) in
            
            imageView.removeFromSuperview()
            blackView.removeFromSuperview()
            transitionContext.completeTransition(true)
            
        }
        
    }
    
    func animationForDissmissed(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromController = transitionContext.viewController(forKey: .from) as! ImagePreviewController
        let originalView = fromController.delegate.photo(of: fromController.selectedIndex, with: fromController).originalView
        guard originalView != nil else {
            transitionContext.completeTransition(true)
            return
        }
        
        let cell = fromController.collectionView.cellForItem(at: IndexPath.init(item: fromController.selectedIndex, section: 0)) as! ImagePreviewCell
        let showView = cell.imageView!
        transitionContext.containerView.addSubview(showView)
        let newRect = originalView!.convert(originalView!.bounds, to: nil)
        UIView.animate(withDuration: fromController.dissmissDuration, animations: {
            
            showView.frame = newRect
            fromController.view.backgroundColor = UIColor.clear
            
        }) { (finish) in
            transitionContext.completeTransition(true)
        }
        
    }
    
}

