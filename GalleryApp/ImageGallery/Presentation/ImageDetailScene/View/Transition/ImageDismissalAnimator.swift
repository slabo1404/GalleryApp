//
//  ImageDismissalAnimator.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 8.03.26.
//

import UIKit

final class ImageDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let image: UIImage?
    private let finalFrame: CGRect
    private let scale: CGFloat
    private let originPosition: CGPoint
    
    init(image: UIImage?, finalFrame: CGRect, scale: CGFloat, originPosition: CGPoint) {
        self.image = image
        self.finalFrame = finalFrame
        self.scale = scale
        self.originPosition = originPosition
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 0
        imageView.clipsToBounds = true
        imageView.frame = containerView.frame
  
        containerView.addSubview(imageView)
        
        if scale < 1 {
            imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }

        let springTiming = UISpringTimingParameters(dampingRatio: 0.9, initialVelocity: CGVector(dx: 0, dy: 2))
        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
        let finalFrame = finalFrame

        animator.addAnimations {
            if self.scale < 1 {
                imageView.transform = CGAffineTransform.identity
            }
            
            imageView.frame = finalFrame
            imageView.layer.cornerRadius = 16
        }
        
        animator.addCompletion { _ in
            imageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        animator.startAnimation()
    }
}
