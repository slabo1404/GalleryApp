//
//  FavouriteCellView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 7.03.26.
//

import SwiftUI

struct FavouriteCellView: View {
    let imageData: Data?
    let onTapped: () -> Void
    
    private let uiImage: UIImage?
    
    init(imageData: Data?, onTapped: @escaping () -> Void) {
        self.imageData = imageData
        self.onTapped = onTapped
        self.uiImage = imageData.flatMap(UIImage.init)
    }
    
    var body: some View {
        Button(action: onTapped) {
            Color.clear
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(contentOverlay)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var contentOverlay: some View {
        if let uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color(uiColor: .systemGray6)
        }
    }
}
