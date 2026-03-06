//
//  CoreDataPhotoStorage.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import CoreData
import Foundation

final class CoreDataPhotoStorage {
    private let storage = CoreDataStorage.shared
}

extension CoreDataPhotoStorage: IPhotoStorage {
    func save(photo: Photo) {
        storage.performBackgroundTask { context in
            do {
                let _ = PhotoEntity(photo: photo, context: context)
                try context.save()
                
            } catch {
                debugPrint("Error save photo: \(error)")
            }
        }
    }
    
    func deletePhoto(id: String) {
        storage.performBackgroundTask { context in
            let request: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let photoEntity = try context.fetch(request).first
                
                if let photoEntity {
                    context.delete(photoEntity)
                    try context.save()
                }
            } catch {
                debugPrint("Error deleting photo: \(error)")
            }
        }
    }
    
    func fetchPhotos() async throws -> [Photo] {
        let context = storage.backgroundContext
        
        return try await context.perform {
            let request: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PhotoEntity.createdAt), ascending: false)]
            
            return try context.fetch(request).map { $0.toDomain() }
        }
    }
}
