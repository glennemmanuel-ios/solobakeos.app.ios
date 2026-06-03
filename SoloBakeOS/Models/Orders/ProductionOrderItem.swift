//
//  ProductionOrderItem.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/3/26.
//

import Foundation
import SwiftData

@Model
class ProductionOrderItem {

    var quantityToBake: Int
    var committedQuantity: Int

    @Relationship var recipe: BreadRecipe
    @Relationship var order: ProductionOrder

    init(quantityToBake: Int, recipe: BreadRecipe, order: ProductionOrder) {
        self.quantityToBake = quantityToBake
        self.committedQuantity = 0
        self.recipe = recipe
        self.order = order
    }

}
