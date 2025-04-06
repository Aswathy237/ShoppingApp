//
//  Product.swift
//  Shopping App
//
//  Created by 61086256 on 06/04/25.
//

import Foundation

struct Product: Identifiable, Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let rating: Rating
    let image: String
    
}

struct Rating: Decodable {
    let rate: Double
    let count: Int
}

struct Favourite {
    var isFavorite: Bool = false // Tracks if the product is favorited
}
