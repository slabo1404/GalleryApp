//
//  DomainMappable.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

protocol DomainMappable {
    associatedtype DomainModel
    
    func toDomain() -> DomainModel
}
