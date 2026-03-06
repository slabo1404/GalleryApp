//
//  PhotoResponseDTO.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

struct PhotoResponseDTO: Codable {
    let id: String
    let slug: String
    let createdAt: Date?
    let description: String?
    let altDescription: String
    let urls: PhotoURLsResponseDTO
    
    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case createdAt = "created_at"
        case description
        case altDescription = "alt_description"
        case urls
    }
}

extension PhotoResponseDTO: DomainMappable {
    func toDomain() -> Photo {
        Photo(
            id: id,
            slug: slug,
            createdAt: createdAt,
            description: description,
            altDescription: altDescription,
            imageUrl: urls.small
        )
    }
}
