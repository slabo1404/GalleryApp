//
//  IPhotoStorage.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

protocol IPhotoStorage {
    func save(photo: Photo)
    func deletePhoto(id: String)
    func fetchPhotos() async throws -> [Photo]
}
