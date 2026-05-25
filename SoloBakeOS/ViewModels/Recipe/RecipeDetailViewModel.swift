//
//  RecipeDetailViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/25/26.
//

import SwiftData
import SwiftUI

extension RecipeDetailView {

    @Observable
    class ViewModel {

        var showUpdatePrice = false
        var newSellingPrice = ""

        var isUpdatePriceValid: Bool {
            guard let price = Double(newSellingPrice) else { return false }
            return price > 0
        }

        func updateSellingPrice(for recipe: BreadRecipe, context: ModelContext) {
            guard let price = Double(newSellingPrice) else { return }
            let entry = RecipePriceHistory(
                sellingPrice: price,
                recipeGroupID: recipe.recipeGroupID
            )
            context.insert(entry)
            try? context.save()
            newSellingPrice = ""
        }

        func costBreakdown(for recipe: BreadRecipe) -> [(name: String, quantity: Double, unit: String, cost: Double)] {
            recipe.recipeIngredients.map { item in
                (
                    name: item.ingredient.name,
                    quantity: item.quantity,
                    unit: item.ingredient.unit == .custom
                        ? item.ingredient.customUnitLabel ?? "units"
                        : item.ingredient.unit.rawValue,
                    cost: ceil(item.quantity * item.ingredient.weightedAverageCost)
                )
            }
            .sorted { $0.cost > $1.cost }
        }

        func marginColor(_ status: BreadRecipe.MarginStatus) -> Color {
            switch status {
            case .good:     return .green
            case .warning:  return .yellow
            case .critical: return .red
            }
        }

        func marginEmoji(_ status: BreadRecipe.MarginStatus) -> String {
            switch status {
            case .good:     return "🟢"
            case .warning:  return "🟡"
            case .critical: return "🔴"
            }
        }
    }
}
