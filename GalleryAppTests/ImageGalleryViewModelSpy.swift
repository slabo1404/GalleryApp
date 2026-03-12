//
//  ImageGalleryViewModelSpy.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 12.03.26.
//

import Combine
import Foundation

@testable import GalleryApp

final class ImageGalleryViewModelSpy: IImageGalleryViewModel {
    var uniquePhotos: [Photo] = []
    let photosSubject = CurrentValueSubject<[Photo], Never>([])
    
    var photosPublisher: AnyPublisher<[Photo], Never> {
        photosSubject.eraseToAnyPublisher()
    }
    
    func fetchPhotoBatch() {
        methodsQueue.append(.track(event: .fetchPhotoBatch))
    }
    
    func prefetchImages(at indexes: [Int]) {}
    func cancelPrefetchImages(at indexes: [Int]) {}
    
    enum Method: Equatable {
        case track(event: TrackingEvents)
    }
    
    private(set) var methodsQueue: [Method] = []
}

enum TrackingEvents: String {
    case fetchPhotoBatch
}
