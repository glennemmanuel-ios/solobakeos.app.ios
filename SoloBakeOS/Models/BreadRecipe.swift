//
//  BreadRecipe.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

@Model
class BreadRecipe {
    
    var name: String
    var version: Int
    var isCurrentVersion: Bool
    var recipeGroupID: UUID // links all versions of the same recipe
    
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
    var recipeIngredients: [RecipeIngredient] = []
    
    init(name: String, version: Int = 1, isCurrentVersion: Bool = true, recipeGroupID: UUID = UUID()) {
        self.name = name
        self.version = version
        self.isCurrentVersion = isCurrentVersion
        self.recipeGroupID = recipeGroupID
    }
    
}

// MARK: - Helper Functions

extension BreadRecipe {

    /// Total ingredient cost to produce `quantity` units.
    /// = Σ(recipeIngredient.quantity × ingredient.weightedAverageCost) × quantity
    func costOfGoods(quantity: Int) -> Double {
        let costPerUnit = recipeIngredients.reduce(0.0) { total, item in
            total + (item.quantity * item.ingredient.weightedAverageCost)
        }
        return costPerUnit * Double(quantity)
    }

    /// Latest selling price for this recipe group.
    /// Accepts all price history records since RecipePriceHistory
    /// is not directly related — it links via recipeGroupID across versions.
    func currentSellingPrice(from priceHistories: [RecipePriceHistory]) -> Double? {
        priceHistories
            .filter { $0.recipeGroupID == recipeGroupID }
            .sorted { $0.date > $1.date }
            .first?
            .sellingPrice
    }

    /// Profit margin as a percentage (0–100).
    /// = (revenue - costOfGoods) / revenue × 100
    func profitMargin(quantity: Int, from priceHistories: [RecipePriceHistory]) -> Double? {
        guard let price = currentSellingPrice(from: priceHistories) else { return nil }
        let revenue = price * Double(quantity)
        guard revenue > 0 else { return nil }
        let cost = costOfGoods(quantity: quantity)
        return ((revenue - cost) / revenue) * 100
    }

}


// MARK: - Margin Status

extension BreadRecipe {

    enum MarginStatus {
        case good       // > 30% 🟢
        case warning    // 15–30% 🟡
        case critical   // < 15% 🔴
    }

    func marginStatus(quantity: Int, from priceHistories: [RecipePriceHistory]) -> MarginStatus? {
        guard let margin = profitMargin(quantity: quantity, from: priceHistories) else { return nil }
        switch margin {
        case 30...:  return .good
        case 15..<30: return .warning
        default:     return .critical
        }
    }

}
