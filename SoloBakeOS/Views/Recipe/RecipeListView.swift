//
//  RecipeListView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/22/26.
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [BreadRecipe]
    @Query private var priceHistories: [RecipePriceHistory]

    @State private var viewModel = ViewModel()
    @State private var showAddRecipe = false

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    var body: some View {
        NavigationStack {
            List(viewModel.filtered(recipes)) { recipe in
                NavigationLink(destination: Text("Recipe Detail — coming soon")) {
                    RecipeRowView(
                        recipe: recipe,
                        priceHistories: priceHistories,
                        currencyCode: currencyCode
                    )
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search recipes")
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddRecipe = true
                    } label: {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if viewModel.filtered(recipes).isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "book",
                        description: Text("Add your first recipe to get started.")
                    )
                }
            }
            .sheet(isPresented: $showAddRecipe) {
                Text("Add Recipe — coming soon")
            }
        }
    }
}

// MARK: - Recipe Row

private struct RecipeRowView: View {
    let recipe: BreadRecipe
    let priceHistories: [RecipePriceHistory]
    let currencyCode: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(recipe.name)
                        .font(.headline)
                    Text("v\(recipe.version)")
                        .font(.caption2)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                        .foregroundStyle(.secondary)
                }
                
                // COG per piece
                let cog = recipe.costOfGoods(quantity: recipe.yield)
                let cogPerPiece = cog / Double(recipe.yield)
                Text("COG: \(cogPerPiece.formatted(.currency(code: currencyCode)))/ \(recipe.perUnitLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Selling price
                if let price = recipe.currentSellingPrice(from: priceHistories) {
                    Text("Price: \(price.formatted(.currency(code: currencyCode)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Yield: \(recipe.yield) \(recipe.perUnitLabel)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Margin badge
            MarginBadge(recipe: recipe, priceHistories: priceHistories)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Margin Badge

private struct MarginBadge: View {
    let recipe: BreadRecipe
    let priceHistories: [RecipePriceHistory]

    var body: some View {
        if let status = recipe.marginStatus(quantity: recipe.yield, from: priceHistories),
           let margin = recipe.profitMargin(quantity: recipe.yield, from: priceHistories) {
            VStack(spacing: 2) {
                Text(statusEmoji(status))
                    .font(.title3)
                Text(String(format: "%.0f%%", margin))
                    .font(.caption)
                    .bold()
                    .foregroundStyle(statusColor(status))
            }
        } else {
            VStack(spacing: 2) {
                Text("—")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("No price")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func statusEmoji(_ status: BreadRecipe.MarginStatus) -> String {
        switch status {
        case .good:     return "🟢"
        case .warning:  return "🟡"
        case .critical: return "🔴"
        }
    }

    private func statusColor(_ status: BreadRecipe.MarginStatus) -> Color {
        switch status {
        case .good:     return .green
        case .warning:  return .yellow
        case .critical: return .red
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(PreviewData.previewContainer)
}
