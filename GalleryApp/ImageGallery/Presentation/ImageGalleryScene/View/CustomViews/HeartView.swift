//
//  HeartView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 5.03.26.
//

import SwiftUI

struct HeartView: View {
    @State private var localIsLiked: Bool
    var isLiked: Bool
    let onTap: (Bool) -> Void
    
    init(isLiked: Bool, onTap: @escaping (Bool) -> Void) {
        self.localIsLiked = isLiked
        self.isLiked = isLiked
        self.onTap = onTap
    }
    
    var body: some View {
        Image(systemName: localIsLiked ? "heart.fill" : "heart")
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(localIsLiked ? .red : .white)
            .scaleEffect(localIsLiked ? 1.2 : 1.0)
            .shadow(color: .black.opacity(0.2), radius: 4)
            .onChange(of: isLiked) { oldValue, newValue in
                if localIsLiked != newValue {
                    localIsLiked = newValue
                }
            }
            .onTapGesture {
                generateImpactFeedback()
                localIsLiked.toggle()
                onTap(localIsLiked)
            }
    }
    
    private func generateImpactFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
}
