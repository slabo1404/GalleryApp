//
//  GalleryAppTests.swift
//  GalleryAppTests
//
//  Created by Вячеслав Болбат on 12.03.26.
//

import Combine
import XCTest

@testable import GalleryApp

@MainActor
final class GalleryAppTests: XCTestCase {
    
    var viewModel: ImageGalleryViewModelSpy!
    var sut: ImageGalleryViewController!
    
    override func setUp() {
        super.setUp()
        
        viewModel = ImageGalleryViewModelSpy()
        sut = ImageGalleryViewController(viewModel: viewModel)
    }
    
    override func tearDown() {
        viewModel = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_fetchingPhotoBatch_viewDidLoaded_should() {
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(viewModel.methodsQueue, [ImageGalleryViewModelSpy.Method.track(event: .fetchPhotoBatch)])
    }
}
