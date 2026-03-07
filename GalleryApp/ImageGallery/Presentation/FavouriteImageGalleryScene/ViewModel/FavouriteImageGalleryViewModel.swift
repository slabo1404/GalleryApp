//
//  FavouriteImageGalleryViewModel.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 7.03.26.
//

import Foundation

protocol IFavouriteImageGalleryViewModelInput {
    func deleteFavouritePhoto(id: String)
}

protocol IFavouriteImageGalleryViewModel: IFavouriteImageGalleryViewModelInput {}

final class FavouriteImageGalleryViewModel: IFavouriteImageGalleryViewModel {
    private let deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase
    
    init(deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase) {
        self.deleteFavouritePhotoUseCase = deleteFavouritePhotoUseCase
    }
    
    func deleteFavouritePhoto(id: String) {
        deleteFavouritePhotoUseCase.start(id: id)
    }
    
}
