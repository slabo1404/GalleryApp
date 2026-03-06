//
//  IImageGalleryRepository.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

protocol IImageGalleryRepository {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo]
    func saveFavouritePhoto(_ photo: Photo)
    func deleteFavouritePhoto(id: String)
    func fetchFavoritePhotos() async throws -> [Photo]
}
