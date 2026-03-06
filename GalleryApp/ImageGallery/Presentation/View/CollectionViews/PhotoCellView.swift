//
//  PhotoCellView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import SwiftUI

struct PhotoCellView: View {
    @State var isLiked: Bool
    @State private var isPressed = false
    @State private var isImageLoaded = false
    
    let photo: Photo
    let onTapped: () -> Void
    let onLikeTapped: (Bool) -> Void
    
    var body: some View {
        Button {
            onTapped()
        } label: {
            LoadingImageView(urlString: photo.imageUrl, isImageLoaded: $isImageLoaded)
                .aspectRatio(1.2, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .topTrailing) {
                    if isImageLoaded {
                        HeartView(isLiked: $isLiked) { isLiked in
                            onLikeTapped(isLiked)
                        }
                        .padding(8)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}
