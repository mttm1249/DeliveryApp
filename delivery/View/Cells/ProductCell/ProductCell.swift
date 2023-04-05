//
//  ProductCell.swift
//  delivery
//
//  Created by mttm on 04.04.2023.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    var dataProvider = DataProvider()
    
    static let reuseIdentifier = "productCell"
    
    private var image: UIImage? {
        didSet {
            productImage.image = image
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
        }
    }
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    func setup(model: ProductContentModel) {
        productPriceLabel.layer.borderColor = #colorLiteral(red: 0.9701812863, green: 0.6653127074, blue: 0.7502200007, alpha: 1)
        productPriceLabel.layer.borderWidth = 1
        productPriceLabel.layer.cornerRadius = 6
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        
        let urlString = model.imageString!
        let url = URL(string: urlString)!
        dataProvider.downloadImage(url: url) { image in
            self.image = image
        }
        productNameLabel.text = model.productName
        productDescriptionLabel.text = model.productDescription
        if model.productPrice != nil {
            productPriceLabel.text = "от \(model.productPrice!) p"
        }
    }
}
