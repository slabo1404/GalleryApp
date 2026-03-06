//
//  ImageGalleryViewModel.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Combine
import Foundation

protocol IImageGalleryViewModelOutput {
    var photosPublisher: AnyPublisher<[Photo], Never> { get }
}

protocol IImageGalleryViewModelInput {
    func fetchPhotoBatch()
    func prefetchImages(at indexes: [Int])
    func cancelPrefetchImages(at indexes: [Int])
    func saveFavouritePhoto(_ photo: Photo)
    func deleteFavouritePhoto(id: String)
}

protocol IImageGalleryViewModel: IImageGalleryViewModelInput, IImageGalleryViewModelOutput {}

final class ImageGalleryViewModel: IImageGalleryViewModel {
    @Published private var photos: [Photo] = []
    private var batchIndex = 0
    private var photosWithDublicates: [Photo] = []
    private var batchLimit = 30
    
    private var canLoadBatch: Bool {
        if photosWithDublicates.isEmpty {
            return true
        }
        
        return batchLimit == photosWithDublicates.count / batchIndex
    }
    
    var photosPublisher: AnyPublisher<[Photo], Never> {
        $photos.eraseToAnyPublisher()
    }

    private let fetchPhotosUseCase: IFetchPhotosUseCase
    private let saveFavouritePhotoUseCase: ISaveFavouritePhotoUseCase
    private let deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase
    
    init(fetchPhotosUseCase: IFetchPhotosUseCase,
         saveFavouritePhotoUseCase: ISaveFavouritePhotoUseCase,
         deleteFavouritePhotoUseCase: IDeleteFavouritePhotoUseCase
    ) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.saveFavouritePhotoUseCase = saveFavouritePhotoUseCase
        self.deleteFavouritePhotoUseCase = deleteFavouritePhotoUseCase
    }
    
    func fetchPhotoBatch() {
        guard canLoadBatch else { return }
        
        batchIndex += 1
        
        Task {
            try await fetchPhotos()
        }
    }
    
    func prefetchImages(at indexes: [Int]) {
        indexes.forEach { index in
            let photoUrl = photos[index].imageUrl
            
            Task {
                await ImageLoader.shared.loadImage(urlString: photoUrl)
            }
        }
    }
    
    func cancelPrefetchImages(at indexes: [Int]) {
        indexes.forEach { index in
            let photoUrl = photos[index].imageUrl
            Task {
                await ImageLoader.shared.cancelLoad(urlString: photoUrl)
            }
        }
    }
    
    func saveFavouritePhoto(_ photo: Photo) {
        saveFavouritePhotoUseCase.start(photo: photo)
        updatePhoto(id: photo.id, isLiked: true)
    }
    
    func deleteFavouritePhoto(id: String) {
        deleteFavouritePhotoUseCase.start(id: id)
        updatePhoto(id: id, isLiked: false)
    }
    
    private func updatePhoto(id: String, isLiked: Bool) {
        photosWithDublicates.indices.forEach { index in
            let photo = photosWithDublicates[index]
            if photo.id == id {
                photosWithDublicates[index].isLiked = isLiked
            }
        }
        
        if let index = photos.firstIndex(where: { $0.id == id }) {
            photos[index].isLiked = isLiked
        }
    }
}

// MARK: - Requests

private extension ImageGalleryViewModel {
    func fetchPhotos() async throws {
        do {
            let batch = try await fetchPhotosUseCase.start(page: batchIndex, perPage: batchLimit)
            
            photosWithDublicates.append(contentsOf: batch)
            photos = photosWithDublicates.unique(by: \.id)
        } catch {
            print(error.localizedDescription)
        }
    }
}
