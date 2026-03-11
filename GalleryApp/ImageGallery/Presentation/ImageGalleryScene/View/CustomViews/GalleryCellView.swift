//
//  GalleryCellView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import SwiftUI

struct GalleryCellView: View {
    @State var image: UIImage?
    
    let photo: Photo
    let onTapped: () -> Void
    
    var body: some View {
        Button {
            if image != nil {
                onTapped()
            }
        } label: {
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.easeOut(duration: 0.3), value: image)
        }
        .buttonStyle(ScaleButtonStyle())
        .task {
            image = await ImageLoader.shared.loadImage(urlString: photo.imageUrl)
        }
        .onDisappear {
            ImageLoader.shared.cancelLoad(urlString: photo.imageUrl)
        }
    }
}
