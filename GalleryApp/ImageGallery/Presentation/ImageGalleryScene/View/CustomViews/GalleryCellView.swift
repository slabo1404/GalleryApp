//
//  GalleryCellView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import SwiftUI

struct GalleryCellView: View {
    @State private var isPressed = false
    @State private var loadedImageData: Data?
    
    let photo: Photo
    let onTapped: () -> Void
    let onLikeTapped: (Bool, Data?) -> Void
    
    var body: some View {
        Button {
            onTapped()
        } label: {
            LoadingImageView(urlString: photo.imageUrl) { imageData in
                loadedImageData = imageData
            }
            .aspectRatio(1.2, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .topTrailing) {
                if let loadedImageData {
                    HeartView(isLiked: photo.isLiked) { isLiked in
                        onLikeTapped(isLiked, loadedImageData)
                    }
                    .padding(8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}
