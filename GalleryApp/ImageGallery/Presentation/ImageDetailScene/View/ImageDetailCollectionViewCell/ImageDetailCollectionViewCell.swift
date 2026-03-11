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
        imageView.alpha = 0
        return imageView
    }()
    
    private let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    } ()
    
    // MARK: - Private properties
    
    private var imageURL: String?
    
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
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Overriden
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let imageURL {
            ImageLoader.shared.cancelLoad(urlString: imageURL)
        }
        
        imageView.image = nil
        imageView.alpha = 0
        loader.stopAnimating()
    }
    
    func configure(with photo: Photo) {
        imageURL = photo.imageUrl
        imageView.image = nil
        imageView.alpha = 0
        loader.startAnimating()
        
        Task {
            let loadedImage = await ImageLoader.shared.loadImage(urlString: photo.imageUrl)
            
            loader.stopAnimating()
            imageView.image = loadedImage
            
            UIView.animate(withDuration: 0.3) {
                self.imageView.alpha = 1
            }
        }
    }
}
