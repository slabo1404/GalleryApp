//
//  PhotoURLsResponseDTO.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

struct PhotoURLsResponseDTO: Codable {
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
