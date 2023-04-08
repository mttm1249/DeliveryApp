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
    var selectedIndexPath: IndexPath?
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
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let roundedView = UIView()
        roundedView.backgroundColor = .white
        roundedView.frame = CGRect(x: 0, y: collectionView.frame.maxY, width: frame.width, height: 30)
        roundedView.layer.cornerRadius = 15
        roundedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(roundedView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            roundedView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -10),
            roundedView.heightAnchor.constraint(equalToConstant: 30)
        ])
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9607843137, blue: 0.9764705882, alpha: 1)
        collectionView.showsHorizontalScrollIndicator = false
        selectedIndexPath = IndexPath(row: 0, section: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SectionHeader: UICollectionViewDelegate, UICollectionViewDataSource {
    func showCategory(cell: UICollectionViewCell, active: Bool) {
        if active {
            cell.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.2274509804, blue: 0.4117647059, alpha: 0.1965542219)
            cell.layer.borderWidth = 0
        } else {
            cell.backgroundColor = .clear
            cell.layer.borderWidth = 1
            cell.layer.borderColor = #colorLiteral(red: 0.9701812863, green: 0.6653127074, blue: 0.7502200007, alpha: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell() }

        cell.textLabel.text = categoryArray[indexPath.row].name
        cell.textLabel.textColor = #colorLiteral(red: 0.9921568627, green: 0.2274509804, blue: 0.4117647059, alpha: 1)
        cell.layer.cornerRadius = 16
        // default select
        if let selectedIndexPath = selectedIndexPath, let cell = collectionView.cellForItem(at: selectedIndexPath) as? CategoryCell {
            showCategory(cell: cell, active: true)
            cell.textLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        }
        // select by category type
        if categoryArray[indexPath.row].type == selectedCategory {
            selectedIndexPath = nil
            showCategory(cell: cell, active: true)
            cell.textLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        } else {
            showCategory(cell: cell, active: false)
            cell.textLabel.font = .systemFont(ofSize: 13, weight: .regular)
        }
        return cell
    }
}

extension SectionHeader: UICollectionViewDelegateFlowLayout {
    func showCategoryCell(active: Bool, cell: UICollectionViewCell, in indexPath: IndexPath) {
        if !active {
            if let selectedIndexPath = selectedIndexPath, let cell = collectionView.cellForItem(at: selectedIndexPath) as? CategoryCell {
                cell.textLabel.font = .systemFont(ofSize: 13, weight: .regular)
                showCategory(cell: cell, active: false)
            }
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return }
            cell.textLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            showCategory(cell: cell, active: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.scrollToSelectedCategory(type: categoryArray[indexPath.row].type)
        if let selectedIndexPath = selectedIndexPath, let cell = collectionView.cellForItem(at: selectedIndexPath) as? CategoryCell {
            cell.textLabel.font = .systemFont(ofSize: 13, weight: .regular)
            showCategory(cell: cell, active: false)
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return }
        cell.textLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        showCategory(cell: cell, active: true)
        selectedIndexPath = indexPath
    }
}

