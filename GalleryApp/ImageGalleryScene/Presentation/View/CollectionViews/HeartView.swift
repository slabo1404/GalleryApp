//
//  HeartView.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 5.03.26.
//

import SwiftUI

struct HeartView: View {
    @Binding var isLiked: Bool
    let onTap: (Bool) -> Void
    
    var body: some View {
        Image(systemName: isLiked ? "heart.fill" : "heart")
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(isLiked ? .red : .white)
            .scaleEffect(isLiked ? 1.2 : 1.0)
            .shadow(color: .black.opacity(0.2), radius: 4)
            .onTapGesture {
                withAnimation(.interactiveSpring()) {
                    generateImpactFeedback()
                    
                    isLiked.toggle()
                    onTap(isLiked)
                }
            }
    }
    
    func generateImpactFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
}
