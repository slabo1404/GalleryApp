//
//  AppDependencyContainer.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import DITranquillity

final class AppDependencyContainer: DIFramework {
    static let container: DIContainer = {
        let container = DIContainer()
        container.append(framework: ImageGalleryFramework.self)
        
        return container
    }()
    
    static func load(container: DIContainer) {}
}
