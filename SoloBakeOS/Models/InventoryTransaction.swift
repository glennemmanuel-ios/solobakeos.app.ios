//
//  InventoryTransaction.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

@Model
class InventoryTransaction {
    
    var date: Date
    var quantity: Double // + for stock-in, - for deductions
    var unitCost: Double? // set on stock-in; WAC snapshot set on deductions
    var reason: Reason
    var note: String?
    
    @Relationship
    var ingredient: Ingredient
    
    init(date: Date, quantity: Double, unitCost: Double? = nil, reason: Reason, note: String? = nil, ingredient: Ingredient) {
        self.date = date
        self.quantity = quantity
        self.unitCost = unitCost
        self.reason = reason
        self.note = note
        self.ingredient = ingredient
    }
    
}


// MARK: - Reason

extension InventoryTransaction {
    
    enum Reason: String, Codable {
        case openingStock
        case manualAdjustment
        case productionOrderConfirmed
        case productionOrderEdited
        case productionOrderVoided
    }
    
}
