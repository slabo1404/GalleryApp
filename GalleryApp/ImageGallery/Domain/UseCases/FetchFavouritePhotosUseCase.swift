//
//  FetchFavouritePhotosUseCase.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

protocol IFetchFavouritePhotosUseCase {
    func start() async throws -> [Photo]
}

final class FetchFavouritePhotosUseCase: IFetchFavouritePhotosUseCase {
    private var repository: IImageGalleryRepository
    
    init(repository: IImageGalleryRepository) {
        self.repository = repository
    }
    
    func start() async throws -> [Photo] {
        try await repository.fetchFavoritePhotos()
    }
}
