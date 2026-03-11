//
//  ImageTransitionCoordinator.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 8.03.26.
//

import UIKit

protocol ImageTransitionDataSource: AnyObject {
    func startImageFrameForItem(at index: Int) -> CGRect
    func finalImageFrameForItem(at index: Int) -> CGRect
    func imageForItem(at index: Int) -> UIImage?
}

protocol ImageTransitionDelegate: AnyObject {
    func currentIndex() -> Int
}

final class ImageTransitionCoordinator: NSObject, UIViewControllerTransitioningDelegate {
    private let dismissInteractor = ImageDismissalInteractor()
    
    private weak var transitionDelegate: ImageTransitionDelegate?
    private weak var transitionDataSource: ImageTransitionDataSource?
    
    init(presentedViewController: ImageDetailViewController, dataSource: ImageTransitionDataSource) {
        super.init()
        
        transitionDataSource = dataSource
        transitionDelegate = presentedViewController
        dismissInteractor.linkGestures(presentedViewController: presentedViewController)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        ImagePresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source
        )
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let currentIndex = transitionDelegate?.currentIndex() ?? 0
        let image = transitionDataSource?.imageForItem(at: currentIndex)
        let startFrame = transitionDataSource?.startImageFrameForItem(at: currentIndex) ?? .zero
        
        return ImagePresenterAnimator(image: image, startFame: startFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let currentIndex = transitionDelegate?.currentIndex() ?? 0
        let finalFrame = transitionDataSource?.finalImageFrameForItem(at: currentIndex) ?? .zero
        let image = transitionDataSource?.imageForItem(at: currentIndex)
        
        return ImageDismissalAnimator(
            image: image,
            finalFrame: finalFrame,
            scale: dismissInteractor.scale ?? 1,
            originPosition: dismissInteractor.originPosition ?? .zero)
        
    }
}
