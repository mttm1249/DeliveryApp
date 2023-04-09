//
//  SectionHeader.swift
//  delivery
//
//  Created by mttm on 03.04.2023.
//

import UIKit

protocol CategoryDelegateProtocol: AnyObject {
    func scrollToSelectedCategory(type: String)
}

struct Category {
    var name: String
    var type: String
}

class SectionHeader: UICollectionReusableView {

    static let reuseIdentifier = "headerView"
    var selectedCategory: String?

    weak var delegate: CategoryDelegateProtocol?
    
    let categoryArray = [Category(name: "Пицца", type: "pizza"),
                         Category(name: "Комбо", type: "combo"),
                         Category(name: "Десерты", type: "dessert"),
                         Category(name: "Напитки", type: "drink")]
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9607843137, blue: 0.9764705882, alpha: 1)
        collectionView.showsHorizontalScrollIndicator = false
        selectedCategory = "pizza"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UICollectionViewDataSource
extension SectionHeader: UICollectionViewDelegate, UICollectionViewDataSource {    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell() }

        cell.textLabel.text = categoryArray[indexPath.row].name

        if categoryArray[indexPath.row].type == selectedCategory {
            cell.isSelectedCell = true
        } else {
            cell.isSelectedCell = false
        }
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension SectionHeader: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.scrollToSelectedCategory(type: categoryArray[indexPath.row].type)
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return }
        if categoryArray[indexPath.row].type == selectedCategory {
            cell.isSelectedCell = true
        } else {
            cell.isSelectedCell = false
        }
    }
}

