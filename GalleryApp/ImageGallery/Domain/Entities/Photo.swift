//
//  Photo.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Foundation

nonisolated struct Photo: Hashable {
    let id: String
    let slug: String
    let createdAt: Date?
    let description: String?
    let altDescription: String
    let imageUrl: String
    var isLiked: Bool = false
    var imageData: Data?
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id && lhs.isLiked == rhs.isLiked
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
