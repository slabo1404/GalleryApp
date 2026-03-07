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
        
        container.register(CoreDataPhotoStorage.init)
            .as(IPhotoStorage.self)
        
        container.register(FetchPhotosUseCase.init(repository:))
            .as(IFetchPhotosUseCase.self)
        
        container.register(SaveFavouritePhotoUseCase.init(repository:))
            .as(ISaveFavouritePhotoUseCase.self)
        
        container.register(DeleteFavouritePhotoUseCase.init(repository:))
            .as(IDeleteFavouritePhotoUseCase.self)
        
        container.register(FetchFavouritePhotosUseCase.init(repository:))
            .as(IFetchFavouritePhotosUseCase.self)
        
        container.register(ImageGalleryViewModel.init(fetchPhotosUseCase:saveFavouritePhotoUseCase:deleteFavouritePhotoUseCase:))
            .as(IImageGalleryViewModel.self)
        container.register(FavouriteImageGalleryViewModel.init(deleteFavouritePhotoUseCase:))
            .as(IFavouriteImageGalleryViewModel.self)
        
        container.register(ImageGalleryViewController.init(viewModel:))
        container.register(FavouriteImageGalleryViewController.init(viewModel:))
    }
    
    
}
