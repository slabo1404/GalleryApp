//
//  ImageGalleryFramework.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import DITranquillity

@MainActor
final class ImageGalleryFramework: @preconcurrency DIFramework {
    static func load(container: DIContainer) {
        container.register(ImageGalleryRepository.init)
            .as(IImageGalleryRepository.self)
        
        container.register(FetchPhotosUseCase.init(repository:))
            .as(IFetchPhotosUseCase.self)
        
        container.register(ImageGalleryViewModel.init(fetchPhotosUseCase:))
            .as(IImageGalleryViewModel.self)
        
        container.register(ImageGalleryViewController.init(viewModel:))
    }
    
    
}
