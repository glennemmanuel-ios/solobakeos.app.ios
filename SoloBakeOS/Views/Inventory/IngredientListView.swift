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
            List(viewModel.filtered(ingredients)) { ingredient in
                NavigationLink(destination: IngredientDetailView(ingredient: ingredient)) {
                    IngredientRowView(ingredient: ingredient)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search ingredients")
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddIngredient = true } label: {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if ingredients.isEmpty {
                    ContentUnavailableView(
                        "No Ingredients",
                        systemImage: "shippingbox",
                        description: Text("Add your first ingredient to get started.")
                    )
                } else if viewModel.filtered(ingredients).isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                }
            }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredientView()
            }
        }
    }
}

// MARK: - Ingredient Row

private struct IngredientRowView: View {
    let ingredient: Ingredient

    private var unitLabel: String {
        ingredient.unit == .custom ? ingredient.customUnitLabel ?? "units" : ingredient.unit.rawValue
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ingredient.name)
                    .font(.headline)
                Text("WAC: \(ingredient.weightedAverageCost.formatted(.currency(code: Locale.currencyCode))) / \(unitLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.2f \(unitLabel)", ingredient.currentStock))
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
}

#Preview {
    IngredientListView()
        .modelContainer(PreviewData.previewContainer)
}
