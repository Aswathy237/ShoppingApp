//
//  ContentView.swift
//  Shopping App
//
//  Created by 61086256 on 06/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var cart: [Product] = [] // Tracks products added to the cart
    @State private var favorites: [Int: Favourite] = [:] // Tracks favorites for products by ID

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()) // Two columns for grid layout
    ]

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    if viewModel.products.isEmpty {
                        // Display progress view while loading
                        ProgressView("Loading Products...")
                            .padding()
                    } else {
                        // LazyVGrid for displaying products
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.products) { product in
                                // Simplify favorites binding
                                let favouriteBinding = Binding(
                                    get: {
                                        favorites[product.id, default: Favourite()]
                                    },
                                    set: {
                                        favorites[product.id] = $0
                                    }
                                )

                                // Wrap product card with NavigationLink to ProductPreview
                                NavigationLink(
                                    destination: ProductPreview(
                                        product: product,
                                        cart: $cart, // Pass cart binding
                                        favorites: $favorites // Pass favorites binding
                                    )
                                ) {
                                    ProductCard(
                                        product: product,
                                        favourite: favouriteBinding, // Pass favourite binding
                                        cart: $cart // Pass cart binding
                                    )
                                }
                            }
                        }
                        .padding() // Add padding around the grid
                    }
                }
                .navigationTitle("Product Store")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ZStack {
                            // Cart Icon
                            NavigationLink(destination: CartView(cart: cart)) {
                                Image(systemName: "cart")
                                    .imageScale(.large)
                            }

                            // Badge for Cart Count
                            if cart.count > 0 { // Show badge only if cart has items
                                Text("\(cart.count)")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18) // Circular badge size
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10) // Position badge on top-right corner
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchProducts()

                    // Initialize favorites dictionary with default values
                    if favorites.isEmpty {
                        for product in viewModel.products {
                            if favorites[product.id] == nil {
                                favorites[product.id] = Favourite()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    @Binding var favourite: Favourite // Tracks the favorite status
    @Binding var cart: [Product]      // Tracks products in the cart

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Image(product.image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(height: 150)

                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)

                Text("Price: $\(product.price, specifier: "%.2f")")
                    .font(.callout)
                    .bold()
                    .foregroundColor(.primary)

                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(product.rating.rate) ? "star.fill" : "star")
                            .foregroundColor(index < Int(product.rating.rate) ? .yellow : .gray)
                    }
                    Text("(\(product.rating.count))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.white))
            .cornerRadius(10)
            .shadow(radius: 2)

            Button(action: {
                favourite.isFavorite.toggle() // Toggle favorite state
                if favourite.isFavorite {
                    cart.append(product) // Add to cart
                } else {
                    cart.removeAll { $0.id == product.id } // Remove from cart
                }
            }) {
                Image(systemName: favourite.isFavorite ? "heart.fill" : "heart") // Dynamic heart icon
                    .foregroundColor(.red)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .padding(10)
        }
        .padding(.vertical, 5)
    }
}

struct CartView: View {
    let cart: [Product] // Cart passed from ContentView
    @State private var showThankYouAlert = false // State to control alert visibility

    var body: some View {
        VStack {
            if cart.isEmpty {
                Text("Your Cart is Empty!")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                // List of Products in the Cart
                List(cart) { product in
                    HStack {
                        Image(product.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .cornerRadius(5)

                        VStack(alignment: .leading) {
                            Text(product.title)
                                .font(.headline)
                            Text("Price: $\(product.price, specifier: "%.2f")")
                                .font(.subheadline)
                        }

                        Spacer()
                    }
                }
                .listStyle(PlainListStyle())

                // "Check Out" Button
                Button(action: {
                    showThankYouAlert = true // Show the Thank You alert
                }) {
                    Text("Check Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                .alert(isPresented: $showThankYouAlert) {
                    Alert(
                        title: Text("Thank You"),
                        message: Text("Your order has been placed successfully!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .navigationTitle("Your Cart")
    }
}

struct ProductPreview: View {
    let product: Product // Selected product
    @Binding var cart: [Product] // Binding to the cart array
    @Binding var favorites: [Int: Favourite] // Binding to favorites to update heart state
    @Environment(\.presentationMode) var presentationMode // Controls dismissal

    var body: some View {
        VStack {
            // Product Image
            Image(product.image)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()

            // Product Details
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(product.rating.rate) ? "star.fill" : "star")
                            .foregroundColor(index < Int(product.rating.rate) ? .yellow : .gray)
                    }
                    Text("(\(product.rating.count))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Text("Price: $\(product.price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)

                Text(product.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(5)
            }
            .padding()

            // "Add to Cart" Button
            Button(action: {
                // Add product to cart if not already there
                if !cart.contains(where: { $0.id == product.id }) {
                    cart.append(product) // Add the product to the cart
                }

                // Mark the product as a favorite in favorites state
                favorites[product.id] = Favourite(isFavorite: true)

                // Close the preview screen
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Add to Cart")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding()

            Spacer()
        }
        .navigationBarItems(
            trailing: Button(action: {
                presentationMode.wrappedValue.dismiss() // Dismiss on Close button click
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        )
        .navigationTitle("Product Preview")
    }
}


#Preview {
    ContentView()
}
