//
//  ImageGalleryViewController.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Combine
import SnapKit
import SwiftUI
import UIKit

final class ImageGalleryViewController: UIViewController {
    // MARK: - Views
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.footerMode = .supplementary
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
            
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(40)
            )
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            
            section.boundarySupplementaryItems = [sectionFooter]
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    // MARK: - Private properties
    
    private var viewModel: IImageGalleryViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Int, Photo>!
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Inits
    
    init(viewModel: IImageGalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViews()
        setupDataSource()
        bindToViewModel()
        
        viewModel.fetchPhotoBatch()
    }
}

// MARK: - UI

private extension ImageGalleryViewController {
    func setupUI() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func setupViews() {
        navigationItem.title = "Галлерея"
        collectionView.prefetchDataSource = self
    }
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Photo> { cell, _, photo in
            cell.selectedBackgroundView = UIView()
            
            cell.contentConfiguration = UIHostingConfiguration {
                PhotoCellView(photo: photo) {
                    print("Select photo \(photo.id)")
                } onLikeTapped: { isLiked in
                    if isLiked {
                        self.viewModel.saveFavouritePhoto(photo)
                    } else {
                        self.viewModel.deleteFavouritePhoto(id: photo.id)
                    }
                }
            }
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration<LoaderFooterView>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { footerView, elementKind, indexPath in }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Photo>(collectionView: collectionView) { [weak self] collectionView, indexPath, photo in
            
            let items = collectionView.numberOfItems(inSection: indexPath.section)
            if indexPath.item == items - 5 {
                self?.viewModel.fetchPhotoBatch()
            }
            
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: photo
            )
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: footerRegistration,
                for: indexPath
            )
        }
    }
}

// MARK: - Bindings

private extension ImageGalleryViewController {
    func bindToViewModel() {
        viewModel.photosPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                var snapshot = NSDiffableDataSourceSnapshot<Int, Photo>()
                snapshot.appendSections([0])
                snapshot.appendItems(photos)
                self?.dataSource.apply(snapshot)
            }
            .store(in: &cancellable)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension ImageGalleryViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchImages(at: indexPaths.map { $0.item })
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        viewModel.cancelPrefetchImages(at: indexPaths.map { $0.item })
    }
}
