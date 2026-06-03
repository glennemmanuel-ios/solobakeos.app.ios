//
//  CreateOrderViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/3/26.
//

import SwiftData
import SwiftUI

extension CreateOrderView {

    @Observable
    class ViewModel {
        var orderRows: [(recipe: BreadRecipe, quantity: String)] = []
        var showRecipePicker = false

        var isFormValid: Bool {
            !orderRows.isEmpty &&
            orderRows.allSatisfy {
                if let qty = Int($0.quantity) { return qty > 0 }
                return false
            }
        }

        var alreadyAdded: [BreadRecipe] {
            orderRows.map(\.recipe)
        }

        func addRecipe(_ recipe: BreadRecipe) {
            guard !orderRows.contains(where: { $0.recipe.persistentModelID == recipe.persistentModelID }) else { return }
            orderRows.append((recipe: recipe, quantity: ""))
        }

        func removeRow(at offsets: IndexSet) {
            orderRows.remove(atOffsets: offsets)
        }

        func shortagePreview(for recipe: BreadRecipe, quantity: Int) -> [IngredientShortage] {
            recipe.recipeIngredients.compactMap { ri in
                let required = ri.quantity * Double(quantity)
                let available = ri.ingredient.currentStock
                let shortage = required - available
                guard shortage > 0 else { return nil }
                return IngredientShortage(
                    ingredientName: ri.ingredient.name,
                    unit: ri.ingredient.unit == .custom
                        ? ri.ingredient.customUnitLabel ?? "units"
                        : ri.ingredient.unit.rawValue,
                    required: required,
                    available: available,
                    shortage: shortage
                )
            }
        }

        func saveAsDraft(context: ModelContext) {
            let order = ProductionOrder()
            context.insert(order)

            for row in orderRows {
                guard let qty = Int(row.quantity) else { continue }
                let item = ProductionOrderItem(quantityToBake: qty, recipe: row.recipe, order: order)
                context.insert(item)
            }

            try? context.save()
        }
    }

    struct IngredientShortage: Identifiable {
        let id = UUID()
        let ingredientName: String
        let unit: String
        let required: Double
        let available: Double
        let shortage: Double
    }
}
