//
//  ImagePresentationController.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 11.03.26.
//

import UIKit

final class ImagePresentationController: UIPresentationController {
    private let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffect = UIVisualEffectView(effect: blurEffect)
        visualEffect.alpha = 0
        return visualEffect
    }()

    override var shouldRemovePresentersView: Bool {
        return false
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        presentingViewController.endAppearanceTransition()
        containerView?.insertSubview(visualEffectView, at: 0)
        visualEffectView.alpha = 1
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        visualEffectView.frame = containerView?.frame ?? .zero
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentingViewController.beginAppearanceTransition(true, animated: true)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.visualEffectView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
        if completed {
            visualEffectView.removeFromSuperview()
        }
    }
}
