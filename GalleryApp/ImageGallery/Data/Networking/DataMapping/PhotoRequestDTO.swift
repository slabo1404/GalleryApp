//
//  PhotoRequestDTO.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

struct PhotoRequestDTO {
    let page: Int
    let perPage: Int
}

extension PhotoRequestDTO: ParameterMappable {
    func toQueryItems() -> [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
            
        ]
    }
}
