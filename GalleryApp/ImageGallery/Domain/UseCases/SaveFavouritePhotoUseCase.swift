//
//  SaveFavouritePhotoUseCase.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

protocol ISaveFavouritePhotoUseCase {
    func start(photo: Photo)
}

final class SaveFavouritePhotoUseCase: ISaveFavouritePhotoUseCase {
    private var repository: IImageGalleryRepository
    
    init(repository: IImageGalleryRepository) {
        self.repository = repository
    }
    
    func start(photo: Photo) {
        repository.saveFavouritePhoto(photo)
    }
}
