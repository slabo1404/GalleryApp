//
//  HTTPHeaders.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Foundation

typealias HTTPHeaders = [String: String]

enum HTTPHeader: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
}
