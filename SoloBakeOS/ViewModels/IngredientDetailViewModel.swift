//
//  IngredientDetailViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/21/26.
//

import SwiftUI
import SwiftData

extension IngredientDetailView {

    @Observable
    class ViewModel {
        // Stock-In form
        var stockInQuantity = ""
        var totalAmountPaid = ""
        var stockInNote = ""

        // Manual Adjustment form
        var adjustmentQuantity = ""
        var adjustmentNote = ""

        // Sheet control
        var showStockIn = false
        var showAdjustment = false

        var computedUnitCost: Double? {
            guard let qty = Double(stockInQuantity), qty > 0,
                  let total = Double(totalAmountPaid), total > 0 else { return nil }
            return total / qty
        }

        var isStockInValid: Bool {
            computedUnitCost != nil
        }

        var isAdjustmentValid: Bool {
            guard let qty = Double(adjustmentQuantity) else { return false }
            return qty != 0
        }

        func saveStockIn(for ingredient: Ingredient, context: ModelContext) {
            guard let qty = Double(stockInQuantity), let unitCost = computedUnitCost else { return }
            let transaction = InventoryTransaction(
                date: .now,
                quantity: qty,
                unitCost: unitCost,
                reason: .manualAdjustment,
                note: stockInNote.isEmpty ? nil : stockInNote,
                ingredient: ingredient
            )
            context.insert(transaction)
            try? context.save()
            resetStockIn()
        }

        func saveAdjustment(for ingredient: Ingredient, context: ModelContext) {
            guard let qty = Double(adjustmentQuantity) else { return }
            let transaction = InventoryTransaction(
                date: .now,
                quantity: qty,
                unitCost: nil,
                reason: .manualAdjustment,
                note: adjustmentNote.isEmpty ? nil : adjustmentNote,
                ingredient: ingredient
            )
            context.insert(transaction)
            try? context.save()
            resetAdjustment()
        }

        private func resetStockIn() {
            stockInQuantity = ""
            totalAmountPaid = ""
            stockInNote = ""
        }

        private func resetAdjustment() {
            adjustmentQuantity = ""
            adjustmentNote = ""
        }

        func formattedCurrency(_ value: Double) -> String {
            let code = Locale.current.currency?.identifier ?? "PHP"
            return value.formatted(.currency(code: code))
        }
    }
}
