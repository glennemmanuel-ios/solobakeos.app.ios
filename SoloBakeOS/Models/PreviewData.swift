//
//  PreviewData.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation

struct PreviewData {
    
    static let flour: Ingredient = .init(name: "Flour", unit: .kg, reorderLevel: 10)
    static let sugar: Ingredient = .init(name: "Sugar", unit: .kg, reorderLevel: 10)
    static let cookingOil: Ingredient = .init(name: "Cooking Oil", unit: .L, reorderLevel: 10)
    
    static func sanityCheck() {
        // Seed transactions (to test WAC + currentStock)
        let t1 = InventoryTransaction(date: .now, quantity: 10, unitCost: 50.0, reason: .openingStock, ingredient: flour)
        let t2 = InventoryTransaction(date: .now, quantity: 5, unitCost: 60.0, reason: .manualAdjustment, ingredient: flour)
        flour.transactions = [t1, t2]
        
        // Verify computed values
        print("Stock: \(flour.currentStock)") // expected: 15
        print("WAC: \(flour.weightedAverageCost)") // expected: (10x50 + 5x60) / 15 = 53.33
        
        // Create recipe and test costing
        let recipe = BreadRecipe(name: "Sourdough", yield: 1)
        let ri = RecipeIngredient(quantity: 0.5, ingredient: flour, recipe: recipe)
        recipe.recipeIngredients = [ri]
        
        let price = RecipePriceHistory(sellingPrice: 120, recipeGroupID: recipe.recipeGroupID)
        
        print("COG (10 loaves):", recipe.costOfGoods(quantity: 10))
        print("Margin:", recipe.profitMargin(quantity: 10, from: [price]) ?? 0.0)
        print("Margin Status:", recipe.marginStatus(quantity: 10, from: [price]) ?? .critical)
    }
}
