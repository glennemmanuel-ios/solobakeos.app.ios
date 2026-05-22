//
//  ContentView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/18/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "chart.bar.fill") {
                Text("Dashboard")
            }

            Tab("Inventory", systemImage: "shippingbox.fill") {
                IngredientListView()
            }

            Tab("Recipes", systemImage: "book.fill") {
                RecipeListView()
            }

            Tab("Orders", systemImage: "list.bullet.clipboard.fill") {
                Text("Orders")
            }
        }
    }
}

#Preview {
    ContentView()
}
