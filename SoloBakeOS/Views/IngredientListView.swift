//
//  IngredientListView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/20/26.
//

import SwiftUI
import SwiftData

struct IngredientListView: View {
    @Query private var ingredients: [Ingredient]
    @State private var viewModel = ViewModel()
    @State private var showAddIngredient = false

    var body: some View {
        NavigationStack {
            List(ingredients) { ingredient in
                HStack {
                    VStack(alignment: .leading) {
                        Text(ingredient.name)
                            .font(.headline)
                        Text("Weighted Average Cost: \(viewModel.formattedWeightedAverageCost(ingredient: ingredient)) / \(ingredient.unit.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("\(ingredient.currentStock, specifier: "%.2f") \(ingredient.unit.rawValue)")
                            .font(.subheadline)
                        if ingredient.currentStock <= ingredient.reorderLevel {
                            Text("Low Stock")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.15))
                                .foregroundStyle(.red)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddIngredient = true } label: {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }
            })
            .navigationTitle("Inventory")
            .overlay {
                if ingredients.isEmpty {
                    ContentUnavailableView("No Ingredients", systemImage: "shippingbox", description: Text("Add your first ingredient to get started."))
                }
            }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredientView()
            }
        }
    }
}

#Preview {
    IngredientListView()
        .modelContainer(PreviewData.previewContainer)
}
