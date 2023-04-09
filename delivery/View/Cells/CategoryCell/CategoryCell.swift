//
//  InnerCell.swift
//  delivery
//
//  Created by mttm on 03.04.2023.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CategoryCell"
        
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.9921568627, green: 0.2274509804, blue: 0.4117647059, alpha: 1)
        return label
    }()
    
    var isSelectedCell: Bool = false {
        didSet {
            if isSelectedCell {
                textLabel.font = .systemFont(ofSize: 13, weight: .semibold)
                backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.2274509804, blue: 0.4117647059, alpha: 0.1965542219)
                layer.borderWidth = 0
            } else {
                textLabel.font = .systemFont(ofSize: 13, weight: .regular)
                backgroundColor = .clear
                layer.borderWidth = 1
                layer.borderColor = #colorLiteral(red: 0.9701812863, green: 0.6653127074, blue: 0.7502200007, alpha: 1)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        textLabelConstraints()
        isSelectedCell = false
        layer.cornerRadius = 16
    }
    
    private func textLabelConstraints() {
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
}
