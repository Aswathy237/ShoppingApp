//
//  ProductViewModel.swift
//  Shopping App
//
//  Created by 61086256 on 06/04/25.
//

import Foundation

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []

    func fetchProducts() {
        // Fetch data from the local JSON file
        if let url = Bundle.main.url(forResource: "products", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.products = decodedProducts
                    self.printProducts()
                }
            } catch {
                print("Error loading JSON: \(error.localizedDescription)")
            }
        } else {
            print("JSON file not found.")
        }
    }
    
    // Method to print products
        private func printProducts() {
            for product in products {
                print("ID: \(product.id), Title: \(product.title), Price: \(product.price), Rating: \(product.rating.rate)/5")
                print("Description: \(product.description)")
                print("Image URL: \(product.image)")
                print("----------")
            }
        }
}

