//
//  Requester.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Foundation

protocol Requester {
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var body: Data? { get }
    var parameters: [String: Any]? { get }
    var queryItems: [String: String]? { get }
}

extension Requester {
    var headers: [String: String]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var queryItems: [String: String]? {
        return nil
    }
}

extension Requester {
    func buildRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: host + path)
        
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        if let body = body {
            request.httpBody = body
        } else if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        return request
    }
}
