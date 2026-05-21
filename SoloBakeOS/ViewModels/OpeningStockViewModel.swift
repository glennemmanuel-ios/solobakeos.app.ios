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
        var totalAmountPaid = ""
        var note = ""
        
        var computedUnitCost: Double? {
            guard let qty = Double(quantity), qty > 0,
                  let total = Double(totalAmountPaid), total > 0 else { return nil }
            return total / qty
        }
        
        var isFormValid: Bool {
            computedUnitCost != nil
        }
        
        func save(for ingredient: Ingredient, context: ModelContext) {
            guard let qty = Double(quantity), let unitCost = computedUnitCost else { return }
            
            let transaction = InventoryTransaction(
                date: .now,
                quantity: qty,
                unitCost: unitCost,
                reason: .openingStock,
                note: note.isEmpty ? nil : note,
                ingredient: ingredient
            )
            context.insert(transaction)
            try? context.save()
        }
    }
    
}
