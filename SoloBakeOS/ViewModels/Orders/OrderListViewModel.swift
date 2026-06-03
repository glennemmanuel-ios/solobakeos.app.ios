//
//  OrderListViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/3/26.
//

import SwiftData
import SwiftUI

extension OrderListView {

    @Observable
    class ViewModel {
        var showVoided = false
        var showCreateOrder = false

        func filtered(_ orders: [ProductionOrder]) -> [ProductionOrder] {
            orders.filter { showVoided ? true : $0.status != .voided }
        }

        /// Groups orders by calendar day, newest first
        func grouped(_ orders: [ProductionOrder]) -> [(date: Date, orders: [ProductionOrder])] {
            let filtered = filtered(orders)
            let calendar = Calendar.current

            let grouped = Dictionary(grouping: filtered) { order in
                calendar.startOfDay(for: order.date)
            }

            return grouped
                .map { (date: $0.key, orders: $0.value.sorted { $0.date > $1.date }) }
                .sorted { $0.date > $1.date }
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
    }
}
