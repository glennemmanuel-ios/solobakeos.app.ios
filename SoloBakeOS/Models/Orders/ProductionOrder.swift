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
    var hasStockShortage: Bool
    var totalCostAtConfirmation: Double

    @Relationship(deleteRule: .cascade, inverse: \ProductionOrderItem.order)
    var items: [ProductionOrderItem] = []

    @Relationship(deleteRule: .cascade, inverse: \ProductionOrderEdit.order)
    var editHistory: [ProductionOrderEdit] = []

    init(
        date: Date = .now,
        status: Status = .draft,
        hasStockShortage: Bool = false,
        totalCostAtConfirmation: Double = 0
    ) {
        self.date = date
        self.status = status
        self.hasStockShortage = hasStockShortage
        self.totalCostAtConfirmation = totalCostAtConfirmation
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
