//
//  PhotoEntity+CoreDataProperties.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//
//

public import Foundation
public import CoreData

public typealias PhotoEntityCoreDataPropertiesSet = NSSet

extension PhotoEntity {

    @nonobjc nonisolated public class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }

    @NSManaged nonisolated public var altDescription: String
    @NSManaged nonisolated public var createdAt: Date?
    @NSManaged nonisolated public var descr: String?
    @NSManaged nonisolated public var id: String
    @NSManaged nonisolated public var imageUrl: String
    @NSManaged nonisolated public var slug: String
    @NSManaged nonisolated public var imageData: Data?
    @NSManaged nonisolated public var isLiked: Bool

}

extension PhotoEntity: Identifiable {}
