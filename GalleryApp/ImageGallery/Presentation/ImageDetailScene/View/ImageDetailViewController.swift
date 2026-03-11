//
//  ImageDetailViewController.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 8.03.26.
//

import Combine
import SnapKit
import UIKit

final class ImageDetailViewController: UIViewController {
    // MARK: - Views
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsetsReference = .none
            section.orthogonalScrollingBehavior = .paging
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        
        return collectionView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.red
        button.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor.white
        
        let action = UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()
    
    private let viewModel: IImageDetailViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Int, Photo>!
    private var transition: ImageTransitionCoordinator?
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Inits
    
    init(viewModel: IImageDetailViewModel, dataSource: ImageTransitionDataSource) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        transition = ImageTransitionCoordinator(
            presentedViewController: self,
            dataSource: dataSource
        )
        transitioningDelegate = transition
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDataSource()
        bindToViewModel()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let currentIndex = currentIndex()
    
        coordinator.animate(alongsideTransition: { [weak self] _ in
            let indexPath = IndexPath(item: currentIndex, section: 0)
            self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        })
    }
}

// MARK: - UI

private extension ImageDetailViewController {
    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.trailing.equalToSuperview().offset(-24)
            make.width.height.equalTo(32)
        }
    }
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ImageDetailCollectionViewCell, Photo> { cell, indexPath, photo in
            cell.selectedBackgroundView = UIView()
            cell.configure(with: photo)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Photo>(collectionView: collectionView) { collectionView, indexPath, photo in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: photo
            )
        }
    }
    
    func scrollToSelectedPhoto() {
        view.layoutIfNeeded()
        
        if let index = viewModel.photos.firstIndex(where: { $0.id == viewModel.selectedPhotoId }) {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - Bindings

extension ImageDetailViewController {
    func bindToViewModel() {
        viewModel.photosPublisher
            .sink { [weak self] photos in
                var snapshot = NSDiffableDataSourceSnapshot<Int, Photo>()
                snapshot.appendSections([0])
                snapshot.appendItems(photos)
                self?.dataSource.apply(snapshot)
                
                self?.scrollToSelectedPhoto()
            }
            .store(in: &cancellable)
    }
}

// MARK: - ImageTransitionDelegate

extension ImageDetailViewController: ImageTransitionDelegate {
    func currentIndex() -> Int {
        let centerPoint = collectionView.center
        
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            return indexPath.item
        }
        
        return 0
    }
}
