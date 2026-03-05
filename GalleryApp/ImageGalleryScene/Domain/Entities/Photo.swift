//
//  Photo.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Foundation

nonisolated struct Photo: Codable, Hashable {
    let id: String
    let slug: String
    let createdAt: String
    let description: String?
    let altDescription: String
    let urls: PhotoURLs
    
    var imageUrl: String {
        return urls.small
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case createdAt = "created_at"
        case description
        case altDescription = "alt_description"
        case urls
    }
}

nonisolated struct PhotoURLs: Codable, Hashable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let smallS3: String
    
    enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb
        case smallS3 = "small_s3"
    }
}
