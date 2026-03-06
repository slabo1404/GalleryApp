//
//  IImageGalleryRepository.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

protocol IImageGalleryRepository {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo]
}
