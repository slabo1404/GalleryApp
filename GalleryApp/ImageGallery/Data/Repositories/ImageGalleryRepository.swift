//
//  ImageGalleryRepository.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

final class ImageGalleryRepository: IImageGalleryRepository {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo] {
        let photoRequest = PhotoRequestDTO(page: page, perPage: perPage)
        
        let request = try ImageGalleryRequester
            .fetchPhotos(photoRequest)
            .buildRequest()
        
        let photosResponse: [PhotoResponseDTO] = try await NetworkManager.manager.send(request)
        return photosResponse.toDomain()
    }
}
