//
//  FavouriteImageGalleryViewModel.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 7.03.26.
//

import Foundation

protocol IFavouriteImageGalleryViewModelInput {
    func deleteFavouritePhoto(photo: Photo)
}

protocol IFavouriteImageGalleryViewModel: IFavouriteImageGalleryViewModelInput {}

final class FavouriteImageGalleryViewModel: IFavouriteImageGalleryViewModel {
    private let deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase
    
    init(deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase) {
        self.deleteFavouritePhotoUseCase = deleteFavouritePhotoUseCase
    }
    
    func deleteFavouritePhoto(photo: Photo) {
        deleteFavouritePhotoUseCase.start(id: photo.id)
        
        var updatedPhoto = photo
        updatedPhoto.isLiked = false
        NotificationCenter.default.post(name: .updateLikeStatus, object: updatedPhoto, userInfo: nil)
    }
    
}
