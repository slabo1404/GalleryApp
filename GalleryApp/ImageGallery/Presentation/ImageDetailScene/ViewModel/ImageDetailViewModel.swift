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
}

protocol IImageDetailViewModelInput {
    func saveFavouritePhoto(_ photo: Photo, imageData: Data?)
    func deleteFavouritePhoto(id: String)
}

protocol IImageDetailViewModel: IImageDetailViewModelInput, IImageDetailViewModelOutput {}

final class ImageDetailViewModel: IImageDetailViewModel {
    @Published var photos: [Photo] = []
    var selectedPhotoId: String?
    
    private let saveFavouritePhotoUseCase: ISaveFavouritePhotoUseCase
    private let deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase
    
    init(saveFavouritePhotoUseCase: ISaveFavouritePhotoUseCase, deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase) {
        self.saveFavouritePhotoUseCase = saveFavouritePhotoUseCase
        self.deleteFavouritePhotoUseCase = deleteFavouritePhotoUseCase
    }
    
    var photosPublisher: AnyPublisher<[Photo], Never> {
        $photos.eraseToAnyPublisher()
    }
    
    func saveFavouritePhoto(_ photo: Photo, imageData: Data?) {
        var updatedPhoto = photo
        updatedPhoto.imageData = imageData
        
        saveFavouritePhotoUseCase.start(photo: updatedPhoto)
        updateLocalPhotos(id: photo.id, isLiked: true)
        //        photosSubject.send(uniquePhotos)
    }
    
    func deleteFavouritePhoto(id: String) {
        deleteFavouritePhotoUseCase.start(id: id)
        updateLocalPhotos(id: id, isLiked: false)
        //        photosSubject.send(uniquePhotos)
    }
    
    private func updateLocalPhotos(id: String, isLiked: Bool) {
        if let index = photos.firstIndex(where: { $0.id == id }) {
            photos[index].isLiked = isLiked
        }
    }
}
