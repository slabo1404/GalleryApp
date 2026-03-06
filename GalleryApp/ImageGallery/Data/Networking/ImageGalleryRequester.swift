//
//  ImageGalleryRequester.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Foundation

enum ImageGalleryRequester {
    case fetchPhotos(PhotoRequestDTO)
}

extension ImageGalleryRequester: Requester {
    var host: String {
        "https://api.unsplash.com"
    }
    
    var path: String {
        switch self {
        case .fetchPhotos:
            return "/photos"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchPhotos:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchPhotos(let request):
            return request.toQueryItems()
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .fetchPhotos:
            return [HTTPHeader.authorization.rawValue: "Client-ID NOT8AAWLfqEhZ1kOx6zEkBW1zz1Xayo7qUy6dT53u30"]
        }
    }
}
