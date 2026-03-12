//
//  FavouriteCellView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 7.03.26.
//

import SwiftUI

struct FavouriteCellView: View {
    var imageData: Data?
    
    private var uiImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            } else {
                Color(uiColor: .systemGray6)
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}
