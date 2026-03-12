//
//  ImageGalleryViewModel.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Combine
import CoreData
import Foundation

protocol IImageGalleryViewModelOutput {
    var uniquePhotos: [Photo] { get }
    var photosPublisher: AnyPublisher<[Photo], Never> { get }
}

protocol IImageGalleryViewModelInput {
    func fetchPhotoBatch()
    func prefetchImages(at indexes: [Int])
    func cancelPrefetchImages(at indexes: [Int])
}

protocol IImageGalleryViewModel: IImageGalleryViewModelInput, IImageGalleryViewModelOutput {}

final class ImageGalleryViewModel: IImageGalleryViewModel {
    private var photosSubject = PassthroughSubject<[Photo], Never>()
    private var updatedLikePhotoSubject = PassthroughSubject<Photo, Never>()
    
    private var photos: [Photo] = []
    private var batchIndex = 0
    private var batchLimit = 30
    private var cancellable = Set<AnyCancellable>()
    
    private var canLoadBatch: Bool {
        if photos.isEmpty {
            return true
        }
        
        return batchLimit == photos.count / batchIndex
    }
    
    var photosPublisher: AnyPublisher<[Photo], Never> {
        photosSubject.eraseToAnyPublisher()
    }
    
    var uniquePhotos: [Photo] {
        photos.unique(by: \.id)
    }
    
    private let fetchPhotosUseCase: IFetchPhotosUseCase
    
    init(fetchPhotosUseCase: IFetchPhotosUseCase) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        
        setupNotification()
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
            
            ImageLoader.shared.cancelLoad(urlString: photoUrl)
        }
    }
    
    func setupNotification() {
        NotificationCenter.default
            .publisher(for: .updateLikeStatus, object: nil)
            .sink { [weak self] notification in
                if let photo = notification.object as? Photo {
                    self?.updatelocalPhotoStorage(isLiked: photo.isLiked, photoID: photo.id)
                }
            }
            .store(in: &cancellable)
    }
    
    func updatelocalPhotoStorage(isLiked: Bool, photoID: String) {
        if let index = photos.firstIndex(where: { $0.id == photoID }) {
            var updatedPhoto = photos[index]
            updatedPhoto.isLiked = isLiked
            
            photos[index] = updatedPhoto
            photosSubject.send(uniquePhotos)
        }
    }
}

// MARK: - Requests

private extension ImageGalleryViewModel {
    func fetchPhotos() async throws {
        do {
            let batch = try await fetchPhotosUseCase.start(page: batchIndex, perPage: batchLimit)
            
            photos.append(contentsOf: batch)
            photosSubject.send(uniquePhotos)
        } catch {
            print(error.localizedDescription)
        }
    }
}
