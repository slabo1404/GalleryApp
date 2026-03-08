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
    var updatedLikePhotoPublisher: AnyPublisher<Photo, Never> { get }
}

protocol IImageGalleryViewModelInput {
    func fetchPhotoBatch()
    func prefetchImages(at indexes: [Int])
    func cancelPrefetchImages(at indexes: [Int])
    func saveFavouritePhoto(_ photo: Photo, imageData: Data?)
    func deleteFavouritePhoto(id: String)
}

protocol IImageGalleryViewModel: IImageGalleryViewModelInput, IImageGalleryViewModelOutput {}

final class ImageGalleryViewModel: IImageGalleryViewModel {
    private var photosSubject = PassthroughSubject<[Photo], Never>()
    private var updatedLikePhotoSubject = PassthroughSubject<Photo, Never>()
    
    private var photos: [Photo] = []
    private var batchIndex = 0
    private var batchLimit = 30
    private var cancellable = Set<AnyCancellable>()
    
    private var uniquePhotos: [Photo] {
        photos.unique(by: \.id)
    }
    
    private var canLoadBatch: Bool {
        if photos.isEmpty {
            return true
        }
        
        return batchLimit == photos.count / batchIndex
    }
    
    var photosPublisher: AnyPublisher<[Photo], Never> {
        photosSubject.eraseToAnyPublisher()
    }
    
    var updatedLikePhotoPublisher: AnyPublisher<Photo, Never> {
        updatedLikePhotoSubject.eraseToAnyPublisher()
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
            Task {
                await ImageLoader.shared.cancelLoad(urlString: photoUrl)
            }
        }
    }
    
    func saveFavouritePhoto(_ photo: Photo, imageData: Data?) {
        var updatedPhoto = photo
        updatedPhoto.imageData = imageData
        
        saveFavouritePhotoUseCase.start(photo: updatedPhoto)
        updateLocalPhotos(id: photo.id, isLiked: true)
        photosSubject.send(uniquePhotos)
    }
    
    func deleteFavouritePhoto(id: String) {
        deleteFavouritePhotoUseCase.start(id: id)
        updateLocalPhotos(id: id, isLiked: false)
        photosSubject.send(uniquePhotos)
    }
    
    func setupNotification() {
        NotificationCenter.default
            .publisher(for: .updateLikeStatus)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.object as? Photo }
            .sink { [weak self] photo in
                guard let self = self else { return }
                
                updateLocalPhotos(id: photo.id, isLiked: false)
                updatedLikePhotoSubject.send(photo)
            }
            .store(in: &cancellable)
    }
    
    private func updateLocalPhotos(id: String, isLiked: Bool) {        
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
            
            photos.append(contentsOf: batch)
            photosSubject.send(uniquePhotos)
        } catch {
            print(error.localizedDescription)
        }
    }
}
