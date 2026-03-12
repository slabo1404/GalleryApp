//
//  ImageDetailViewModel.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 11.03.26.
//

import Combine
import Foundation

protocol IImageDetailViewModelOutput {
    var photos: [Photo] { get set }
    var selectedPhotoId: String? { get set }
    
    var photosPublisher: AnyPublisher<[Photo], Never> { get }
    var updatedLikePhotoPublisher: AnyPublisher<Photo, Never> { get }
}

protocol IImageDetailViewModelInput {
    func updateFavouritePhoto(photo: Photo, imageData: Data?, isLiked: Bool)
}

protocol IImageDetailViewModel: IImageDetailViewModelInput, IImageDetailViewModelOutput {}

final class ImageDetailViewModel: IImageDetailViewModel {
    @Published var photos: [Photo] = []
    private var updatedLikePhotoSubject = PassthroughSubject<Photo, Never>()
    var selectedPhotoId: String?
    
    private let saveFavouritePhotoUseCase: ISaveFavouritePhotoUseCase
    private let deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase
    
    init(saveFavouritePhotoUseCase: ISaveFavouritePhotoUseCase,
         deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase
    ) {
        self.saveFavouritePhotoUseCase = saveFavouritePhotoUseCase
        self.deleteFavouritePhotoUseCase = deleteFavouritePhotoUseCase
    }
    
    var photosPublisher: AnyPublisher<[Photo], Never> {
        $photos.eraseToAnyPublisher()
    }
    
    var updatedLikePhotoPublisher: AnyPublisher<Photo, Never> {
        updatedLikePhotoSubject.eraseToAnyPublisher()
    }
    
    func updateFavouritePhoto(photo: Photo, imageData: Data?, isLiked: Bool) {
        var updatedPhoto = photo
        updatedPhoto.isLiked = isLiked
        updatedPhoto.imageData = imageData
        
        if isLiked {
            saveFavouritePhotoUseCase.start(photo: updatedPhoto)
        } else {
            deleteFavouritePhotoUseCase.start(id: photo.id)
        }
        
        NotificationCenter.default.post(name: .updateLikeStatus, object: updatedPhoto)
        
        updatedLikePhotoSubject.send(updatedPhoto)
    }
}
