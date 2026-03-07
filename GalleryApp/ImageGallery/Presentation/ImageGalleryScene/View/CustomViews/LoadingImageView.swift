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
    
    var onImageDataLoaded: (Data?) -> Void
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .transition(.opacity)
            } else {
                ProgressView()
            }
        }
        .animation(.easeOut(duration: 0.3), value: image)
        .task {
            let loadedImage = await ImageLoader.shared.loadImage(urlString: urlString)
            
            if loadedImage != nil {
                image = loadedImage
                onImageDataLoaded(loadedImage?.jpegData(compressionQuality: 0.8))
            }
        }
    }
}
