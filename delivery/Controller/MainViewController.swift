//
//  MainViewController.swift
//  delivery
//
//  Created by mttm on 03.04.2023.

import UIKit

enum Section: Int, CaseIterable {
    case banner
    case products
}

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let sectionHeader = SectionHeader()
    
    private var lastContentOffset: CGFloat = 0
    private var currentProductType: String?
    private var banners = [ProductContentModel]()
    private var products = [ProductContentModel]()
    private var dataSource: DataSource!
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductContentModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ProductContentModel>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionHeader.delegate = self
        collectionView.delegate = self
        fetch()
        configureCollectionView()
        configureDataSource()
    }
    
    // MARK: Fetch data from JSON
    private func fetch() {
        let url = URLManager.shared.apiURL
        NetworkManager.shared.loadJson(urlString: url) {
            [weak self] (result: Result<ProductsContent, Error>) in
            switch result {
            case .success(let data):
                let fetchedProducts = data
                for product in fetchedProducts {
                    let productContent = ProductContentModel(productName: product.productName,
                                                             productDescription: product.productDescription,
                                                             productPrice: product.productPrice,
                                                             productType: product.productType,
                                                             imageString: product.imageString)
                    
                    if productContent.productType == "banner" {
                        self?.banners.append(productContent)
                    } else {
                        self?.products.append(productContent)
                    }
                }
                self?.applySnapshot()
            case .failure(let error):
                print("WE GOT ERROR: \(error.localizedDescription)")
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: Сonfigure CollectionView
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseIdentifier)
        let productCell = UINib(nibName: "ProductCell", bundle: nil)
        collectionView.register(productCell, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        
        let bannerCell = UINib(nibName: "BannerCell", bundle: nil)
        collectionView.register(bannerCell, forCellWithReuseIdentifier: BannerCell.reuseIdentifier)
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    // MARK: Create Layout for CollectionView
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets.leading = 16
                item.contentInsets.bottom = 20
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(300), heightDimension: .absolute(140)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                return section
            } else if sectionIndex == 1 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                // background for section
                let sectionInset: CGFloat = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)
                let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
                let backgroundInset: CGFloat = 0
                backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: 70, leading: backgroundInset, bottom: backgroundInset, trailing: backgroundInset)
                section.decorationItems = [backgroundItem]
                
                // MARK: HEADER WITH CATEGORY SELECTOR
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                sectionHeader.contentInsets.leading = -16
                sectionHeader.contentInsets.trailing = -16
                section.boundarySupplementaryItems = [sectionHeader]
                sectionHeader.pinToVisibleBounds = true
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
        // register background for section
        layout.register(SectionBackground.self, forDecorationViewOfKind: "background")
        return layout
    }
    
    // MARK: Сonfigure CollectionViewDataSource
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section)  else {
                fatalError("Unknown section kind")
            }
            switch section {
            case .banner:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: BannerCell.reuseIdentifier,
                    for: indexPath) as? BannerCell
                cell?.setup(model: self.banners[indexPath.item])
                return cell
            case .products:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseIdentifier, for: indexPath) as? ProductCell
                cell?.setup(model: self.products[indexPath.item])
                return cell
            }
        })
        // Adding section header
        dataSource.supplementaryViewProvider = { [self] (collectionView, kind, indexPath) in
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseIdentifier, for: indexPath) as? SectionHeader
            headerView?.delegate = self
            return headerView
        }
        applySnapshot()
    }
    
    // MARK: Snapshot
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.banner, .products])
        snapshot.appendItems(banners, toSection: .banner)
        snapshot.appendItems(products, toSection: .products)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: Scroll to product method
extension MainViewController: CategoryDelegateProtocol {
    func scrollToSelectedCategory(type: String) {
        let index = products.firstIndex(where: { $0.productType == type })
        if let index = index {
            let indexPath = IndexPath(item: index, section: 1)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
}

// MARK: Activation of a button equal to the category type
extension MainViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            let productType = products[indexPath.item].productType
            if productType != currentProductType {
                currentProductType = productType
                
                guard let productType = productType else { return }
                
                let visibleSections = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
                guard let firstSection = visibleSections.first?.section else { return }
                guard let sectionHeader = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: firstSection)) as? SectionHeader else { return }
                sectionHeader.selectedCategory = productType
                
                let indexPaths = sectionHeader.collectionView.indexPathsForVisibleItems
                if let lastIndexPath = indexPaths.last, scrollView.contentOffset.y > lastContentOffset {
                    sectionHeader.collectionView.scrollToItem(at: lastIndexPath, at: .centeredHorizontally, animated: true)
                    sectionHeader.collectionView.reloadItems(at: indexPaths)
                } else if let firstIndexPath = indexPaths.first {
                    sectionHeader.collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
                    sectionHeader.collectionView.reloadItems(at: indexPaths)
                }
                lastContentOffset = scrollView.contentOffset.y
            }
        }
    }
}







