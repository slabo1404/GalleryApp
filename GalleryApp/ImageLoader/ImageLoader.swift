//
//  ImageLoader.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 5.03.26.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let session: URLSession
    private let cache = NSCache<NSString, UIImage>()
    private var activeTasks: [String: Task<UIImage?, Never>] = [:]
    
    private init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
    }
    
    func geImageFromCache(key: String) -> UIImage? {
        getFromCache(key: key)
    }
    
    func loadImage(urlString: String) async -> UIImage? {
        if let cachedImage = getFromCache(key: urlString) {
            return cachedImage
        }
        
        if let existingTask = activeTasks[urlString] {
            return await existingTask.value
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        let task = Task {
            do {
                try Task.checkCancellation()
                
                let (data, _) = try await session.data(from: url)
                let image = UIImage(data: data)
                if let image = image {
                    setInCache(image, key: urlString)
                }
                return image
            } catch {
                return nil
            }
        }
        
        activeTasks[urlString] = task
        let image = await task.value
        activeTasks[urlString] = nil
        
        return image
    }
    
    func cancelLoad(urlString: String) {
        activeTasks[urlString]?.cancel()
        activeTasks[urlString] = nil
    }
    
    private func getFromCache(key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    private func setInCache(_ image: UIImage, key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
