//
//  AddRecipeViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/25/26.
//

import SwiftData
import SwiftUI

extension AddRecipeView {

    @Observable
    class ViewModel {

        // Basic info
        var name = ""
        var yieldAmount = ""
        var yieldUnit: BreadRecipe.YieldUnit = .pieces
        var customYieldLabel = ""
        var initialSellingPrice = ""

        // Ingredient rows — (ingredient, quantity string)
        var ingredientRows: [(ingredient: Ingredient, quantity: String)] = []

        // Sheet control
        var showIngredientPicker = false

        var isFormValid: Bool {
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
                  let yield = Int(yieldAmount), yield > 0,
                  let price = Double(initialSellingPrice), price > 0,
                  (yieldUnit != .custom || !customYieldLabel.trimmingCharacters(in: .whitespaces).isEmpty),
                  !ingredientRows.isEmpty else { return false }

            return ingredientRows.allSatisfy {
                if let qty = Double($0.quantity) { return qty > 0 }
                return false
            }
        }

        func addIngredient(_ ingredient: Ingredient) {
            guard !ingredientRows.contains(where: { $0.ingredient.persistentModelID == ingredient.persistentModelID }) else { return }
            ingredientRows.append((ingredient: ingredient, quantity: ""))
        }

        func removeIngredient(at offsets: IndexSet) {
            ingredientRows.remove(atOffsets: offsets)
        }

        @discardableResult
        func save(context: ModelContext) -> BreadRecipe {
            let yield = Int(yieldAmount) ?? 1
            let price = Double(initialSellingPrice) ?? 0

            let recipe = BreadRecipe(
                name: name.trimmingCharacters(in: .whitespaces),
                yield: yield,
                yieldUnit: yieldUnit
            )

            if yieldUnit == .custom {
                recipe.customYieldLabel = customYieldLabel.trimmingCharacters(in: .whitespaces)
            }

            for row in ingredientRows {
                guard let qty = Double(row.quantity) else { continue }
                let recipeIngredient = RecipeIngredient(
                    quantity: qty,
                    ingredient: row.ingredient,
                    recipe: recipe
                )
                context.insert(recipeIngredient)
            }

            let priceHistory = RecipePriceHistory(
                sellingPrice: price,
                recipeGroupID: recipe.recipeGroupID
            )

            context.insert(recipe)
            context.insert(priceHistory)
            try? context.save()

            return recipe
        }
    }
}
