//
//  FavouriteImageGalleryViewController.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 7.03.26.
//

import CoreData
import DITranquillity
import SnapKit
import SwiftUI
import UIKit

final class FavouriteImageGalleryViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { [weak self] _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            
            let itemsCount = self?.dataSource?.snapshot().numberOfItems ?? 0
            config.footerMode = .supplementary
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, _ in
                    guard let photo = self?.dataSource.itemIdentifier(for: indexPath) else { return }
                    
                    self?.viewModel.deleteFavouritePhoto(photo: photo)
                }
                deleteAction.image = UIImage(systemName: "trash")
                
                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    // MARK: - Private properties
    
    private var viewModel: IFavouriteImageGalleryViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Int, Photo>!
    private var fetchResultsController: NSFetchedResultsController<PhotoEntity>!
    
    // MARK: - Inits
    
    init(viewModel: IFavouriteImageGalleryViewModel) {
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
        setupFetchResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        try? fetchResultsController.performFetch()
    }
}

// MARK: - UI

private extension FavouriteImageGalleryViewController {
    func setupUI() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func setupViews() {
        navigationItem.title = "Любимые"
    }
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Photo> { cell, _, photo in
            cell.selectedBackgroundView = UIView()
            
            cell.contentConfiguration = UIHostingConfiguration {
                FavouriteCellView(imageData: photo.imageData) { [weak self] in
                    self?.showImageDeatailScene(with: photo)
                }
            }
            .margins(.all, 0)
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] footerView, _, _ in
            let isEmpty = self?.dataSource.snapshot().numberOfItems == 0
            
            self?.configureFooterView(footerView, isEmpty: isEmpty)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Photo>(
            collectionView: collectionView
        ) { collectionView, indexPath, photo in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: photo
            )
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionFooter {
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
            }
            return nil
        }
    }
    
    func setupFetchResultsController() {
        let request: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PhotoEntity.createdAt), ascending: false)]
        
        fetchResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataStorage.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchResultsController.delegate = self
    }
    
    func configureFooterView(_ footer: UICollectionViewListCell, isEmpty: Bool) {
        var config = footer.defaultContentConfiguration()
        config.text = isEmpty ? "Нет любимых картинок" : ""
        config.textProperties.alignment = .center
        config.textProperties.color = .secondaryLabel
        footer.contentConfiguration = config
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FavouriteImageGalleryViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        guard let entities = controller.fetchedObjects as? [PhotoEntity] else { return }
        
        let photos = entities.map { $0.toDomain() }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Photo>()
        snapshot.appendSections([0])
        snapshot.appendItems(photos)
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            if let footerView = self?.collectionView.visibleSupplementaryViews(
                ofKind: UICollectionView.elementKindSectionFooter
            ).first as? UICollectionViewListCell {
                
                self?.configureFooterView(footerView, isEmpty: photos.isEmpty)
            }
        }
    }
}

// MARK: - ImageTransitionDelegate

extension FavouriteImageGalleryViewController: ImageTransitionDataSource {
    func startImageFrameForItem(at index: Int) -> CGRect {
        let indexPath = IndexPath(item: index, section: 0)
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return .zero
        }
        
        let cellFrame = cell.convert(cell.contentView.frame, to: nil)
        
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 8
        
        let imageFrame = cellFrame.inset(by: UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        ))
        
        return imageFrame
    }
    
    func finalImageFrameForItem(at index: Int) -> CGRect {
        let indexPath = IndexPath(item: index, section: 0)
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return .zero
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        collectionView.layoutIfNeeded()
        
        let cellFrame = cell.convert(cell.contentView.frame, to: nil)
        
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 8
        
        let imageFrame = cellFrame.inset(by: UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        ))
        
        return imageFrame
    }
    
    func imageForItem(at index: Int) -> UIImage? {
        let photos = dataSource.snapshot().itemIdentifiers
        
        if index < photos.count {
            let photo = photos[index]
            
            if let imageData = photo.imageData {
                return UIImage(data: imageData)
            }
        }
        
        return nil
    }
}

// MARK: - Navigation

private extension FavouriteImageGalleryViewController {
    func showImageDeatailScene(with photo: Photo) {
        var imageDetailViewModel: IImageDetailViewModel = AppDependencyContainer.container.resolve()
        imageDetailViewModel.photos = dataSource.snapshot().itemIdentifiers
        imageDetailViewModel.selectedPhotoId = photo.id
        
        let imageDetailViewController = ImageDetailViewController(
            viewModel: imageDetailViewModel,
            dataSource: self
        )
        
        present(imageDetailViewController, animated: true)
    }
}
