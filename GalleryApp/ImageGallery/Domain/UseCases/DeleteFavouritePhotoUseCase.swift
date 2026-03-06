//
//  DeleteFavouritePhotoUseCase.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

protocol IDeleteFavouritePhotoUseCase {
    func start(id: String)
}

final class DeleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase {
    private var repository: IImageGalleryRepository
    
    init(repository: IImageGalleryRepository) {
        self.repository = repository
    }
    
    func start(id: String) {
        repository.deleteFavouritePhoto(id: id)
    }
}
