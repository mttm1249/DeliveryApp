//
//  ProductContentModel.swift
//  delivery
//
//  Created by mttm on 04.04.2023.
//

import Foundation

struct ProductContentModel: Codable, Hashable {
    var id = UUID()
    var productName: String?
    var productDescription: String?
    var productPrice: Int?
    var productType: String?
    var imageString: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ProductContentModel, rhs: ProductContentModel) -> Bool {
        return lhs.id == rhs.id
    }
}
