//
//  FetchPhotosUseCase.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

protocol IFetchPhotosUseCase {
    func start(page: Int, perPage: Int) async throws -> [Photo]
}

final class FetchPhotosUseCase: IFetchPhotosUseCase {
    private var repository: IImageGalleryRepository
    
    init(repository: IImageGalleryRepository) {
        self.repository = repository
    }
    
    func start(page: Int, perPage: Int) async throws -> [Photo] {
        try await repository.fetchPhotos(page: page, perPage: perPage)
    }
}
