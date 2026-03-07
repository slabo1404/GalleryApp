//
//  ImageGalleryRepository.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Foundation

final class ImageGalleryRepository: IImageGalleryRepository {
    private let photoStorage: IPhotoStorage
    
    init(photoStorage: IPhotoStorage) {
        self.photoStorage = photoStorage
    }
    
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo] {
        let photoRequest = PhotoRequestDTO(page: page, perPage: perPage)
        
        let request = try ImageGalleryRequester
            .fetchPhotos(photoRequest)
            .buildRequest()
        
        async let favouritePhotos: [Photo] = fetchFavoritePhotos()
        async let photoResponse: [PhotoResponseDTO] = NetworkManager.manager.send(request)
        
        let (favPhotos, photos) = try await (favouritePhotos, photoResponse)
        
        let favouritePhotoIDs = favPhotos.map { $0.id }
        let domainPhotos = photos.toDomain()
        
        let updatedPhotos = domainPhotos.map { photo in
            var updatedPhoto = photo
            updatedPhoto.isLiked = favouritePhotoIDs.contains(photo.id)
            return updatedPhoto
        }
    
        return updatedPhotos
    }
    
    func saveFavouritePhoto(_ photo: Photo) {
        photoStorage.save(photo: photo)
    }
    
    func deleteFavouritePhoto(id: String) {
        photoStorage.deletePhoto(id: id)
    }
    
    func fetchFavoritePhotos() async throws -> [Photo] {
        return try await photoStorage.fetchPhotos()
    }
}
