//
//  Ingredient.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import SwiftData

@Model
class Ingredient {
    
    var name: String
    var unit: Unit
    var customUnitLabel: String?
    var reorderLevel: Double
    
    @Relationship(deleteRule: .cascade, inverse: \InventoryTransaction.ingredient)
    var transactions: [InventoryTransaction] = []
    
    var currentStock: Double {
        let total = transactions.map(\.quantity).reduce(0, +)
        return total
    }
    
    var weightedAverageCost: Double {
        let stockIns = transactions.filter { $0.quantity > 0 && $0.unitCost != nil }
        let totalQty = stockIns.reduce(0.0) { $0 + $1.quantity
        }
        let totalCost = stockIns.reduce(0.0) { $0 + ($1.quantity * $1.unitCost!)
        }
        guard totalQty > 0 else { return 0 }
        return totalCost / totalQty
    }
    
    init(name: String, unit: Unit, reorderLevel: Double) {
        self.name = name
        self.unit = unit
        self.reorderLevel = reorderLevel
    }
    
}


// MARK: - Ingredient.Unit

extension Ingredient {
    
    enum Unit: String, Codable, CaseIterable {
        
        case g
        case kg
        case ml
        case L
        case pcs
        case tsp
        case tbsp
        case custom
        
    }
    
}
