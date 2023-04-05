//
//  MainViewController.swift
//  delivery
//
//  Created by mttm on 03.04.2023.

import UIKit

enum Section: Int, CaseIterable {
    case banner
    case category
    case products
}

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    private let sectionHeader = SectionHeader()

    private var banners = [ProductContentModel]()
    private var products = [ProductContentModel]()
    private var dataSource: DataSource!

    typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductContentModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ProductContentModel>

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionHeader.delegate = self
        fetch()
        configureCollectionView()
        configureDataSource()
    }

    // MARK: Fetch data from JSON
    private func fetch() {
        let url = URLManager.shared.mainScreenURL
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
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(0), heightDimension: .absolute(0)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(0), heightDimension: .absolute(0)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else if sectionIndex == 2 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)

                // MARK: HEADER WITH CATEGORY SELECTOR
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
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
            case .category:
                break
            }
            return UICollectionViewCell()
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
        snapshot.appendSections([.banner, .category, .products])
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
            let indexPath = IndexPath(item: index, section: 2)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
}
