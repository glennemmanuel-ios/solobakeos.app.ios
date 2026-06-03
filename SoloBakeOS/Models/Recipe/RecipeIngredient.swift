//
//  RecipeIngredient.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

@Model
class RecipeIngredient {
    
    var quantity: Double
    
    @Relationship var ingredient: Ingredient
    @Relationship var recipe: BreadRecipe
    
    init(quantity: Double, ingredient: Ingredient, recipe: BreadRecipe) {
        self.quantity = quantity
        self.ingredient = ingredient
        self.recipe = recipe
    }
    
}
