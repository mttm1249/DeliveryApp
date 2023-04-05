//
//  BannerCell.swift
//  delivery
//
//  Created by mttm on 05.04.2023.
//

import UIKit

class BannerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "bannerCell"
    
    var dataProvider = DataProvider()
    
    private var image: UIImage? {
        didSet {
            bannerImage.image = image
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
        }
    }
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    func setup(model: ProductContentModel) {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        
        let urlString = model.imageString!
        let url = URL(string: urlString)!
        dataProvider.downloadImage(url: url) { image in
            self.image = image
        }
    }
}
