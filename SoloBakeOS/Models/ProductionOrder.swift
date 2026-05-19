//
//  ProductionOrder.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

@Model
class ProductionOrder {
    
    var date: Date
    var status: Status
    var quantityToBake: Int
    var committedQuantity: Int
    var hasStockShortage: Bool
    var totalCostAtConfirmation: Double
    
    @Relationship var recipe: BreadRecipe
    
    @Relationship(deleteRule: .cascade, inverse: \ProductionOrderEdit.order)
    var editHistory: [ProductionOrderEdit] = []
    
    init(date: Date = .now, status: Status = .draft, quantityToBake: Int, committedQuantity: Int = 0, hasStockShortage: Bool = false, totalCostAtConfirmation: Double = 0, recipe: BreadRecipe) {
        self.date = date
        self.status = status
        self.quantityToBake = quantityToBake
        self.committedQuantity = committedQuantity
        self.hasStockShortage = hasStockShortage
        self.totalCostAtConfirmation = totalCostAtConfirmation
        self.recipe = recipe
    }
    
}


// MARK: - Status

extension ProductionOrder {
    
    enum Status: String, Codable {
        case draft
        case confirmed
        case voided
    }
    
}
