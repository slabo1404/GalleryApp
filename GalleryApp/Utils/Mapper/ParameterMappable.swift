//
//  ParameterMappable.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 6.03.26.
//

import Foundation

protocol ParameterMappable {
    func toParameters() -> [String: Any]
    func toQueryItems() -> [URLQueryItem]
}

extension ParameterMappable {
    func toParameters() -> [String: Any] { [:] }
    func toQueryItems() -> [URLQueryItem] { [] }
}
