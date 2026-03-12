//
//  PhotoEntity+Mapping.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import CoreData
import Foundation

extension PhotoEntity {
    nonisolated convenience init(photo: Photo, context: NSManagedObjectContext) {
        self.init(context: context)
        
        setValue(photo.id, forKey: "id")
        setValue(photo.slug, forKey: "slug")
        setValue(photo.createdAt, forKey: "createdAt")
        setValue(photo.description, forKey: "descr")
        setValue(photo.altDescription, forKey: "altDescription")
        setValue(photo.imageUrl, forKey: "imageUrl")
        setValue(photo.imageData, forKey: "imageData")
    }
}

extension PhotoEntity: DomainMappable {
    nonisolated func toDomain() -> Photo {
        Photo(
            id: id,
            slug: slug,
            createdAt: createdAt,
            description: descr,
            altDescription: altDescription,
            imageUrl: imageUrl,
            imageData: imageData
        )
    }
}
