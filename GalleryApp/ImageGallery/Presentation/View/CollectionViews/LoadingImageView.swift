//
//  LoadingImageView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 5.03.26.
//

import SwiftUI

struct LoadingImageView: View {
    let urlString: String
    @State private var image: UIImage?
    @Binding var isImageLoaded: Bool
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            } else {
                ProgressView()
            }
        }
        .animation(.easeIn(duration: 0.2), value: image)
        .task {
            let loadedImage = await ImageLoader.shared.loadImage(urlString: urlString)
            
            if loadedImage != nil {
                image = loadedImage
                isImageLoaded = true
            }
        }
    }
}
