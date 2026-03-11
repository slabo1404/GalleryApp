//
//  ImagePresenterAnimator.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 8.03.26.
//

import UIKit

final class ImagePresenterAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let image: UIImage?
    private let startFame: CGRect
    
    init(image: UIImage?, startFame: CGRect) {
        self.image = image
        self.startFame = startFame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        toVC.view.alpha = 0

        let containerView = transitionContext.containerView
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.frame = startFame
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
    
        containerView.addSubview(imageView)
        containerView.addSubview(toVC.view)

        let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
        let duration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)

        animator.addAnimations {
            imageView.layer.cornerRadius = 16
            imageView.frame = containerView.frame
        }

        animator.addCompletion { _ in
            toVC.view.alpha = 1
            imageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator.startAnimation()
    }
}
