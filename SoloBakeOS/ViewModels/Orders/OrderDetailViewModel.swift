//
//  OrderDetailViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/4/26.
//

import SwiftUI
import SwiftData

extension OrderDetailView {

    @Observable
    class ViewModel {
        var showEditOrder = false
        var showVoidConfirmation = false
        var showShortageAlert = false
        var pendingShortages: [ProductionOrderService.ShortageResult] = []

        // Keyed by ProductionOrderItem.persistentModelID
        var editQuantities: [PersistentIdentifier: String] = [:]

        func prepareEdit(from order: ProductionOrder) {
            editQuantities = Dictionary(
                uniqueKeysWithValues: order.items.map {
                    ($0.persistentModelID, String($0.committedQuantity))
                }
            )
        }

        func statusColor(_ status: ProductionOrder.Status) -> Color {
            switch status {
            case .draft:     return .orange
            case .confirmed: return .green
            case .voided:    return .secondary
            }
        }

        func statusLabel(_ status: ProductionOrder.Status) -> String {
            switch status {
            case .draft:     return "Draft"
            case .confirmed: return "Confirmed"
            case .voided:    return "Voided"
            }
        }

        func statusIcon(_ status: ProductionOrder.Status) -> String {
            switch status {
            case .draft:     return "clock.fill"
            case .confirmed: return "checkmark.circle.fill"
            case .voided:    return "xmark.circle.fill"
            }
        }
    }
}
