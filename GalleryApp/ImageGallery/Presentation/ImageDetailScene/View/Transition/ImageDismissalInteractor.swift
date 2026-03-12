//
//  ImageDismissalInteractor.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 8.03.26.
//

import UIKit

final class ImageDismissalInteractor: UIPercentDrivenInteractiveTransition {
    private weak var presentedViewController: ImageDetailViewController?
    var scale: CGFloat?
    var originPosition: CGPoint?

    func linkGestures(presentedViewController: ImageDetailViewController) {
        self.presentedViewController = presentedViewController
        setupGestureRecognizer(in: presentedViewController.view)
    }

    private func setupGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }

    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translationY = gestureRecognizer.translation(in: gestureRecognizer.view?.superview).y
        
        let threshold: CGFloat = 400
        let progress = min(max(translationY / threshold, 0), 1)
        let scale = 1.0 - progress

        switch gestureRecognizer.state {
        case .changed:
            if progress > 0.1 {
                self.scale = scale
                self.originPosition = self.presentedViewController?.view.frame.origin
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }

            UIView.animate(withDuration: 0.1) {
                self.presentedViewController?.view.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1) {
                self.presentedViewController?.view.transform = CGAffineTransform.identity
            }
        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ImageDismissalInteractor: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: gesture.view).y
            
            return velocity > 0
        }

        return false
    }
}
