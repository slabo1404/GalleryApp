//
//  Collection+Mapper.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

extension Collection where Iterator.Element: DomainMappable {
    func toDomain() -> [Element.DomainModel] {
        map { $0.toDomain() }
    }
}
