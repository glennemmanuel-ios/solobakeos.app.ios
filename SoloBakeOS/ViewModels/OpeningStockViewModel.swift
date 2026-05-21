//
//  OpeningStockViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/21/26.
//

import Foundation
import SwiftUI
import SwiftData

extension OpeningStockSheet {
    
    @Observable
    class ViewModel {
        var quantity = ""
        var unitCost = ""
        var note = ""
        
        var isFormValid: Bool {
            guard let qty = Double(quantity), let cost = Double(unitCost) else { return false }
            return qty > 0 && cost > 0
        }
        
        func save(for ingredient: Ingredient, context: ModelContext) {
            guard let qty = Double(quantity), let cost = Double(unitCost) else { return }
            
            let transaction = InventoryTransaction(
                date: .now,
                quantity: qty,
                unitCost: cost,
                reason: .openingStock,
                note: note.isEmpty ? nil : note,
                ingredient: ingredient
            )
            context.insert(transaction)
            try? context.save()
        }
    }
    
}
