//
//  ImageDetailCollectionViewCell.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 11.03.26.
//

import Lottie
import SnapKit
import UIKit

final class ImageDetailCollectionViewCell: UICollectionViewCell {
    // MARK: - Views
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.clipsToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor.red
        imageView.alpha = 0
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.alpha = 0
        return label
    }()
    
    private let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let likeAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView()
        let likePath = Bundle.main.path(forResource: "animate_like", ofType: "json") ?? ""
        animationView.animation = LottieAnimation.filepath(likePath)
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 2
        animationView.alpha = 0
        return animationView
    }()
    
    // MARK: - Private properties
    
    private var imageURL: String?
    
    // MARK: - Public properties
    
    var onLikeTapped: ((Data?, Bool) -> Void)?
    
    var photo: Photo? {
        didSet {
            guard let photo else { return }
            
            configure(with: photo)
        }
    }
    
    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(loader)
        containerView.addSubview(likeAnimationView)
        containerView.addSubview(descriptionLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        likeAnimationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(100)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(-16)
        }
    }
    
    private func setupViews() {
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(didPressLike))
        likeAnimationView.addGestureRecognizer(tapViewGesture)
    }
    
    private func configure(with photo: Photo) {
        if imageURL == photo.imageUrl && imageView.image != nil {
            return
        }
        
        likeAnimationView.currentProgress = photo.isLiked ? 0.5 : 1
        descriptionLabel.text = photo.description ?? photo.altDescription
        imageURL = photo.imageUrl
        imageView.image = nil
        imageView.alpha = 0
        likeAnimationView.alpha = 0
        descriptionLabel.alpha = 0
        loader.startAnimating()
        
        Task {
            let loadedImage = await ImageLoader.shared.loadImage(urlString: photo.imageUrl)
            
            loader.stopAnimating()
            imageView.image = loadedImage
            
            UIView.animate(withDuration: 0.3) {
                self.imageView.alpha = 1
                self.likeAnimationView.alpha = 1
                self.descriptionLabel.alpha = 1
            }
        }
    }
}

// MARK: - Events

extension ImageDetailCollectionViewCell {
    @objc func didPressLike() {
        guard let photo else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
        
        let fromProgress: CGFloat = photo.isLiked ? 0.5 : 0
        let toProgress: CGFloat = photo.isLiked ? 1 : 0.5
        
        let isLiked = photo.isLiked
        
        let imageData = imageView.image?.pngData()
        onLikeTapped?(imageData, !isLiked)
        
        likeAnimationView.play(
            fromProgress: fromProgress,
            toProgress: toProgress,
            loopMode: .playOnce
        )
    }
}
