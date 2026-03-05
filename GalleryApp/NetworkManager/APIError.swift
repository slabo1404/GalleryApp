//
//  APIError.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case httpError(Int, Data)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Authentication required"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Too many requests, please try again later"
        case .serverError(let code):
            return "Server error (\(code))"
        case .httpError(let code, _):
            return "HTTP error (\(code))"
        case .decodingFailed(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}
