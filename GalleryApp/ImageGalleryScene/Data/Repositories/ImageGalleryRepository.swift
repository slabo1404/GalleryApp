//
//  ImageGalleryRepository.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

final class ImageGalleryRepository: IImageGalleryRepository {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo] {
        let request = try ImageGalleryRequester
            .fetchPhotos(page: page, perPage: perPage)
            .buildRequest()
        
        return try await NetworkManager.manager.send(request)
    }
}
