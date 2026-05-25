//
//  PreviewData.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

struct PreviewData {
    
    static let flour: Ingredient = .init(name: "Flour", unit: .kg, reorderLevel: 10)
    static let rawSugar: Ingredient = .init(name: "Raw Sugar", unit: .kg, reorderLevel: 10)
    static let cookingOil: Ingredient = .init(name: "Cooking Oil", unit: .L, reorderLevel: 5)
    static let bakingPowder: Ingredient = .init(name: "Baking Powder", unit: .kg, reorderLevel: 5)
    static let milkPowder: Ingredient = .init(name: "Milk Powder", unit: .kg, reorderLevel: 10)
    static let salt: Ingredient = .init(name: "Salt", unit: .kg, reorderLevel: 10)
    static let dessicatedCoconut: Ingredient = .init(name: "Dessicated Coconut", unit: .kg, reorderLevel: 0.5)
    
    static var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Ingredient.self, RecipeIngredient.self, BreadRecipe.self, RecipePriceHistory.self, InventoryTransaction.self, configurations: config)

        // Seed transactions
        let t1 = InventoryTransaction(date: .now, quantity: 25, unitCost: 39, reason: .openingStock, ingredient: flour)
        let t2 = InventoryTransaction(date: .now, quantity: 50, unitCost: 54, reason: .openingStock, ingredient: rawSugar)
        let t3 = InventoryTransaction(date: .now, quantity: 13, unitCost: 101, reason: .openingStock, ingredient: cookingOil)
        let t4 = InventoryTransaction(date: .now, quantity: 14, unitCost: 57.15, reason: .openingStock, ingredient: bakingPowder)
        let t5 = InventoryTransaction(date: .now, quantity: 25, unitCost: 162, reason: .openingStock, ingredient: milkPowder)
        let t6 = InventoryTransaction(date: .now, quantity: 25, unitCost: 16, reason: .openingStock, ingredient: salt)
        let t7 = InventoryTransaction(date: .now, quantity: 1, unitCost: 190, reason: .openingStock, ingredient: dessicatedCoconut)
        flour.transactions = [t1]
        rawSugar.transactions = [t2]
        cookingOil.transactions = [t3]
        bakingPowder.transactions = [t4]
        milkPowder.transactions = [t5]
        salt.transactions = [t6]
        dessicatedCoconut.transactions = [t7]
        // ... rest of your seeds

        let all = [flour, rawSugar, cookingOil, bakingPowder, milkPowder, salt, dessicatedCoconut]
        for item in all {
            container.mainContext.insert(item)
        }
        
        let recipe = BreadRecipe(name: "Sliced Mamon", yield: 1, yieldUnit: .tray)
        let r1 = RecipeIngredient(quantity: 0.6, ingredient: flour, recipe: recipe)
        let r2 = RecipeIngredient(quantity: 0.5, ingredient: rawSugar, recipe: recipe)
        let r3 = RecipeIngredient(quantity: 0.185, ingredient: cookingOil, recipe: recipe)
        let r4 = RecipeIngredient(quantity: 0.005, ingredient: bakingPowder, recipe: recipe)
        let r5 = RecipeIngredient(quantity: 0.018, ingredient: milkPowder, recipe: recipe)
        let r6 = RecipeIngredient(quantity: 0.0003, ingredient: salt, recipe: recipe)
        let r7 = RecipeIngredient(quantity: 0.0156, ingredient: dessicatedCoconut, recipe: recipe)
        recipe.recipeIngredients = [r1, r2, r3, r4, r5, r6, r7]
        
        let price = RecipePriceHistory(sellingPrice: 280, recipeGroupID: recipe.recipeGroupID)
        
        container.mainContext.insert(recipe)
        container.mainContext.insert(price)
        
        let pandesalPrice = RecipePriceHistory(sellingPrice: 4.0, recipeGroupID: pandesal.recipeGroupID)
        container.mainContext.insert(pandesal)
        container.mainContext.insert(pandesalPrice)
        
        try? container.mainContext.save()
        
        return container
    }
    
    static var pandesal: BreadRecipe {
        let recipe = BreadRecipe(name: "Pandesal", yield: 24, yieldUnit: .pieces)
        let ri1 = RecipeIngredient(quantity: 0.5, ingredient: flour, recipe: recipe)
        let ri2 = RecipeIngredient(quantity: 0.05, ingredient: rawSugar, recipe: recipe)
        let ri3 = RecipeIngredient(quantity: 0.01, ingredient: salt, recipe: recipe)
        recipe.recipeIngredients = [ri1, ri2, ri3]
        return recipe
    }
    
    static func sanityCheck() {
        // Seed transactions (to test WAC + currentStock)
        let t1 = InventoryTransaction(date: .now, quantity: 25, unitCost: 39, reason: .openingStock, ingredient: flour)
        let t2 = InventoryTransaction(date: .now, quantity: 50, unitCost: 54, reason: .openingStock, ingredient: rawSugar)
        let t3 = InventoryTransaction(date: .now, quantity: 13, unitCost: 101, reason: .openingStock, ingredient: cookingOil)
        let t4 = InventoryTransaction(date: .now, quantity: 14, unitCost: 57.15, reason: .openingStock, ingredient: bakingPowder)
        let t5 = InventoryTransaction(date: .now, quantity: 25, unitCost: 162, reason: .openingStock, ingredient: milkPowder)
        let t6 = InventoryTransaction(date: .now, quantity: 25, unitCost: 16, reason: .openingStock, ingredient: salt)
        let t7 = InventoryTransaction(date: .now, quantity: 1, unitCost: 190, reason: .openingStock, ingredient: dessicatedCoconut)
        flour.transactions = [t1]
        rawSugar.transactions = [t2]
        cookingOil.transactions = [t3]
        bakingPowder.transactions = [t4]
        milkPowder.transactions = [t5]
        salt.transactions = [t6]
        dessicatedCoconut.transactions = [t7]
        
        // Create recipe and test costing
        let recipe = BreadRecipe(name: "Sliced Mamon", yield: 1)
        let r1 = RecipeIngredient(quantity: 0.6, ingredient: flour, recipe: recipe)
        let r2 = RecipeIngredient(quantity: 0.5, ingredient: rawSugar, recipe: recipe)
        let r3 = RecipeIngredient(quantity: 0.185, ingredient: cookingOil, recipe: recipe)
        let r4 = RecipeIngredient(quantity: 0.005, ingredient: bakingPowder, recipe: recipe)
        let r5 = RecipeIngredient(quantity: 0.018, ingredient: milkPowder, recipe: recipe)
        let r6 = RecipeIngredient(quantity: 0.0003, ingredient: salt, recipe: recipe)
        let r7 = RecipeIngredient(quantity: 0.0156, ingredient: dessicatedCoconut, recipe: recipe)
        recipe.recipeIngredients = [r1, r2, r3, r4, r5, r6, r7]
        
        let price = RecipePriceHistory(sellingPrice: 280, recipeGroupID: recipe.recipeGroupID)
        
        print("COG (1 tray):", recipe.costOfGoods(quantity: 1))
        print("Margin:", recipe.profitMargin(quantity: 1, from: [price]) ?? 0.0)
        print("Margin Status:", recipe.marginStatus(quantity: 1, from: [price]) ?? .critical)
    }
}
