//
//  ImageGalleryViewController.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 4.03.26.
//

import Combine
import DITranquillity
import SnapKit
import SwiftUI
import UIKit

final class ImageGalleryViewController: UIViewController {
    // MARK: - Views
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/3)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            let section = NSCollectionLayoutSection(group: group)
            
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
        view.backgroundColor = UIColor.white
        navigationItem.title = "Галерея"
        collectionView.prefetchDataSource = self
    }
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Photo> { cell, _, photo in
            cell.selectedBackgroundView = UIView()
            
            cell.contentConfiguration = UIHostingConfiguration { [weak self] in
                GalleryCellView(photo: photo) {
                    self?.showImageDeatailScene(with: photo)
                }
            }
            .margins(.all, 0)
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration<LoaderFooterView>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { _, _, _ in }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Photo>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, photo in
            
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
        
        dataSource.supplementaryViewProvider = { (collectionView, _, indexPath) in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: footerRegistration,
                for: indexPath
            )
        }
    }
    
    private func showImageDeatailScene(with photo: Photo) {
        var imageDetailViewModel: IImageDetailViewModel = AppDependencyContainer.container.resolve()
        imageDetailViewModel.photos = viewModel.uniquePhotos
        imageDetailViewModel.selectedPhotoId = photo.id
        
        let imageDetailViewController = ImageDetailViewController(
            viewModel: imageDetailViewModel,
            dataSource: self
        )
        
        present(imageDetailViewController, animated: true)
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

// MARK: - ImageTransitionDelegate

extension ImageGalleryViewController: ImageTransitionDataSource {
    func startImageFrameForItem(at index: Int) -> CGRect {
        let indexPath = IndexPath(item: index, section: 0)
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return .zero
        }
        
        return cell.convert(cell.contentView.frame, to: nil)
    }
    
    func finalImageFrameForItem(at index: Int) -> CGRect {
        let indexPath = IndexPath(item: index, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        collectionView.layoutIfNeeded()
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return .zero
        }
        
        return cell.convert(cell.contentView.frame, to: nil)
    }
    
    func imageForItem(at index: Int) -> UIImage? {
        let photo = viewModel.uniquePhotos[index]
        return ImageLoader.shared.geImageFromCache(key: photo.imageUrl)
    }
}
