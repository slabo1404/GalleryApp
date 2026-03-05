//
//  MenuTabBarController.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import DITranquillity
import UIKit

final class MenuTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        overrideUserInterfaceStyle = .light
        
        setupTabBarAppearance()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let imageGalleryVC: ImageGalleryViewController = AppDependencyContainer.container.resolve()
        
        viewControllers = [
            createNavigationController(root: imageGalleryVC, title: "Галлерея", icon: "text.bubble.badge.clock")
        ]
    }
    
    private func createNavigationController(root: UIViewController, title: String, icon: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        appearance.shadowImage = nil
        appearance.shadowColor = nil 
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.compactAppearance = appearance
        
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: "\(icon).fill")
        )
        
        return nav
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
