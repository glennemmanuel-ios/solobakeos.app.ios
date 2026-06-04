//
//  ProductionOrderServices.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/4/26.
//

import SwiftData
import Foundation

struct ProductionOrderService {

    // MARK: - Confirm

    static func confirm(_ order: ProductionOrder, context: ModelContext) -> [ShortageResult] {
        var shortages: [ShortageResult] = []
        var totalCost: Double = 0

        for item in order.items {
            let recipe = item.recipe
            let qty = item.quantityToBake

            for ri in recipe.recipeIngredients {
                let ingredient = ri.ingredient
                let required = ri.quantity * Double(qty)
                let wac = ingredient.weightedAverageCost

                // Check shortage — non-blocking
                if ingredient.currentStock < required {
                    shortages.append(ShortageResult(
                        ingredientName: ingredient.name,
                        unit: ingredient.unit == .custom
                            ? ingredient.customUnitLabel ?? "units"
                            : ingredient.unit.rawValue,
                        required: required,
                        available: ingredient.currentStock,
                        shortage: required - ingredient.currentStock
                    ))
                }

                // Write negative transaction — WAC snapshot as unitCost
                let transaction = InventoryTransaction(
                    date: .now,
                    quantity: -required,
                    unitCost: wac,
                    reason: .productionOrderConfirmed,
                    ingredient: ingredient
                )
                context.insert(transaction)

                totalCost += required * wac
            }

            item.committedQuantity = qty
        }

        order.status = .confirmed
        order.totalCostAtConfirmation = ceil(totalCost)
        order.hasStockShortage = !shortages.isEmpty

        try? context.save()

        return shortages
    }

    // MARK: - Edit (delta reversal)

    static func edit(
        _ order: ProductionOrder,
        newQuantities: [PersistentIdentifier: Int], // ProductionOrderItem.id → new qty
        context: ModelContext
    ) {
        var totalCost: Double = 0
        var changeLines: [String] = []

        for item in order.items {
            guard let newQty = newQuantities[item.persistentModelID] else { continue }
            let delta = newQty - item.committedQuantity
            guard delta != 0 else { continue }

            let recipe = item.recipe
            changeLines.append("\(recipe.name): \(item.committedQuantity) → \(newQty) \(recipe.yieldUnit.rawValue)")

            for ri in recipe.recipeIngredients {
                let ingredient = ri.ingredient
                let deltaQty = ri.quantity * Double(delta)
                let wac = ingredient.weightedAverageCost

                // Positive delta = more needed (negative transaction)
                // Negative delta = reversal (positive transaction)
                let transaction = InventoryTransaction(
                    date: .now,
                    quantity: -deltaQty,
                    unitCost: wac,
                    reason: .productionOrderEdited,
                    ingredient: ingredient
                )
                context.insert(transaction)
            }

            item.committedQuantity = newQty
            item.quantityToBake = newQty
        }

        // Recompute total cost from scratch
        for item in order.items {
            for ri in item.recipe.recipeIngredients {
                totalCost += ri.quantity * Double(item.committedQuantity) * ri.ingredient.weightedAverageCost
            }
        }
        order.totalCostAtConfirmation = ceil(totalCost)

        // Log the edit
        let description = changeLines.joined(separator: "\n")
        let edit = ProductionOrderEdit(changeDescription: description, order: order)
        context.insert(edit)

        try? context.save()
    }

    // MARK: - Void

    static func void(_ order: ProductionOrder, context: ModelContext) {
        for item in order.items {
            let recipe = item.recipe

            for ri in recipe.recipeIngredients {
                let ingredient = ri.ingredient
                let originalDeduction = ri.quantity * Double(item.committedQuantity)
                let wac = ingredient.weightedAverageCost

                // Full reversal — restore stock
                let transaction = InventoryTransaction(
                    date: .now,
                    quantity: originalDeduction, // positive = restoring stock
                    unitCost: wac,
                    reason: .productionOrderVoided,
                    ingredient: ingredient
                )
                context.insert(transaction)
            }
        }

        order.status = .voided
        order.hasStockShortage = false

        let edit = ProductionOrderEdit(
            changeDescription: "Order voided. All stock deductions reversed.",
            order: order
        )
        context.insert(edit)

        try? context.save()
    }

    // MARK: - Shortage Result

    struct ShortageResult: Identifiable {
        let id = UUID()
        let ingredientName: String
        let unit: String
        let required: Double
        let available: Double
        let shortage: Double
    }
}
