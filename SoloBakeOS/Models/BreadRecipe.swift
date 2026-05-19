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
