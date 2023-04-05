//
//  ProductModel.swift
//  delivery
//
//  Created by mttm on 04.04.2023.
//

import Foundation

// MARK: - ProductContent
struct ProductContent: CodableModel {
    let productName: String
    let productDescription: String
    let productPrice: Int
    let productType: String
    let imageString: String
}

typealias ProductsContent = [ProductContent]
