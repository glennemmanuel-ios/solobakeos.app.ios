//
//  DashboardView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/4/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var orders: [ProductionOrder]
    @Query private var ingredients: [Ingredient]
    @Query private var recipes: [BreadRecipe]
    @Query private var priceHistories: [RecipePriceHistory]

    private var todayOrders: [ProductionOrder] {
        let calendar = Calendar.current
        return orders
            .filter { calendar.isDateInToday($0.date) && $0.status != .voided }
            .sorted { $0.date > $1.date }
    }

    private var lowStockIngredients: [Ingredient] {
        ingredients
            .filter { $0.currentStock <= $0.reorderLevel }
            .sorted { $0.currentStock < $1.currentStock }
    }

    private var currentRecipes: [BreadRecipe] {
        recipes.filter { $0.isCurrentVersion }
    }

    private var topRecipesByMargin: [BreadRecipe] {
        currentRecipes
            .filter { $0.profitMargin(quantity: $0.yield, from: priceHistories) != nil }
            .sorted {
                ($0.profitMargin(quantity: $0.yield, from: priceHistories) ?? 0) >
                ($1.profitMargin(quantity: $1.yield, from: priceHistories) ?? 0)
            }
            .prefix(5)
            .map { $0 }
    }

    private var criticalRecipes: [BreadRecipe] {
        currentRecipes.filter {
            $0.marginStatus(quantity: $0.yield, from: priceHistories) == .critical
        }
    }

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Today's Orders
                Section {
                    if todayOrders.isEmpty {
                        Label("No orders today.", systemImage: "tray")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(todayOrders) { order in
                            NavigationLink(destination: OrderDetailView(order: order)) {
                                TodayOrderRowView(order: order)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Today's Orders")
                        Spacer()
                        Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Low Stock Alerts
                if !lowStockIngredients.isEmpty {
                    Section {
                        ForEach(lowStockIngredients) { ingredient in
                            NavigationLink(destination: IngredientDetailView(ingredient: ingredient)) {
                                LowStockRowView(ingredient: ingredient)
                            }
                        }
                    } header: {
                        Label("Low Stock", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - Costing Alerts
                if !criticalRecipes.isEmpty {
                    Section {
                        ForEach(criticalRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                CriticalRecipeRowView(recipe: recipe, priceHistories: priceHistories)
                            }
                        }
                    } header: {
                        Label("Critical Margin", systemImage: "chart.line.downtrend.xyaxis")
                            .foregroundStyle(.red)
                    } footer: {
                        Text("These recipes have a margin below 15%. Consider updating their selling price.")
                    }
                }

                // MARK: - Top Recipes by Margin
                if !topRecipesByMargin.isEmpty {
                    Section("Top Recipes by Margin") {
                        ForEach(topRecipesByMargin) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                TopRecipeRowView(recipe: recipe, priceHistories: priceHistories)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - Today Order Row

private struct TodayOrderRowView: View {
    let order: ProductionOrder

    private var statusColor: Color {
        switch order.status {
        case .draft:     return .orange
        case .confirmed: return .green
        case .voided:    return .secondary
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(order.items.map { $0.recipe.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .lineLimit(2)
                Text("\(order.items.count) recipe\(order.items.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(order.status.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .foregroundStyle(statusColor)
                    .clipShape(Capsule())

                if order.status == .confirmed {
                    Text(order.totalCostAtConfirmation.formatted(.currency(code: Locale.currencyCode)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Low Stock Row

private struct LowStockRowView: View {
    let ingredient: Ingredient

    private var unitLabel: String {
        ingredient.unit == .custom
            ? ingredient.customUnitLabel ?? "units"
            : ingredient.unit.rawValue
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.subheadline)
                Text("Reorder at \(String(format: "%.2f", ingredient.reorderLevel)) \(unitLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f \(unitLabel)", ingredient.currentStock))
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.red)
                Text("in stock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Critical Recipe Row

private struct CriticalRecipeRowView: View {
    let recipe: BreadRecipe
    let priceHistories: [RecipePriceHistory]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.subheadline)
                Text("COG: \(recipe.costPerUnit.formatted(.currency(code: Locale.currencyCode))) \(recipe.perUnitLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("🔴")
                    .font(.title3)
                if let margin = recipe.profitMargin(quantity: recipe.yield, from: priceHistories) {
                    Text(String(format: "%.1f%%", margin))
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.red)
                } else {
                    Text("No price")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Top Recipe Row

private struct TopRecipeRowView: View {
    let recipe: BreadRecipe
    let priceHistories: [RecipePriceHistory]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.subheadline)
                Text("v\(recipe.version) · \(recipe.yieldLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let status = recipe.marginStatus(quantity: recipe.yield, from: priceHistories),
                   let margin = recipe.profitMargin(quantity: recipe.yield, from: priceHistories) {
                    Text(status.marginEmoji)
                        .font(.title3)
                    Text(String(format: "%.1f%%", margin))
                        .font(.caption)
                        .bold()
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    DashboardView()
        .modelContainer(PreviewData.previewContainer)
}
