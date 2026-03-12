//
//  ImageDetailCollectionViewCell.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 11.03.26.
//

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
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.red
        button.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        button.alpha = 0
        
        let action = UIAction { [weak self] _ in
            let isLiked = self?.photo?.isLiked ?? false
            self?.configureLikeButton(isLiked: !isLiked)
            
            let imageData = self?.imageView.image?.pngData()
            self?.onLikeTapped?(imageData, !isLiked)
        }
        
        button.addAction(action, for: .touchUpInside)
        
        return button
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(loader)
        containerView.addSubview(likeButton)
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
        
        likeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(24)
            make.width.height.equalTo(28)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(-16)
        }
    }
    
    private func configure(with photo: Photo) {
        configureLikeButton(isLiked: photo.isLiked)
        
        if imageURL == photo.imageUrl && imageView.image != nil {
            return
        }
        
        descriptionLabel.text = photo.description ?? photo.altDescription
        imageURL = photo.imageUrl
        imageView.image = nil
        imageView.alpha = 0
        likeButton.alpha = 0
        descriptionLabel.alpha = 0
        loader.startAnimating()
        
        Task {
            let loadedImage = await ImageLoader.shared.loadImage(urlString: photo.imageUrl)
            
            loader.stopAnimating()
            imageView.image = loadedImage
            
            UIView.animate(withDuration: 0.3) {
                self.imageView.alpha = 1
                self.likeButton.alpha = 1
                self.descriptionLabel.alpha = 1
            }
        }
    }
    
    private func configureLikeButton(isLiked: Bool) {
        let image = isLiked
        ? UIImage(systemName: "heart.fill")
        : UIImage(systemName: "heart")
        likeButton.setBackgroundImage(image, for: .normal)
    }
}
