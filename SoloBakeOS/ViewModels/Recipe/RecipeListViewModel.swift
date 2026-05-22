//
//  RecipeListViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/22/26.
//

import SwiftData
import SwiftUI

extension RecipeListView {
    
    @Observable
    class ViewModel {
        var searchText = ""

        func filtered(_ recipes: [BreadRecipe]) -> [BreadRecipe] {
            let current = recipes.filter { $0.isCurrentVersion }
            guard !searchText.isEmpty else { return current }
            return current.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        func marginStatus(for recipe: BreadRecipe, priceHistories: [RecipePriceHistory]) -> BreadRecipe.MarginStatus? {
            recipe.marginStatus(quantity: recipe.yield, from: priceHistories)
        }

        func currentSellingPrice(for recipe: BreadRecipe, priceHistories: [RecipePriceHistory]) -> Double? {
            recipe.currentSellingPrice(from: priceHistories)
        }

        func costOfGoods(for recipe: BreadRecipe) -> Double {
            recipe.costOfGoods(quantity: recipe.yield)
        }
    }
    
}
