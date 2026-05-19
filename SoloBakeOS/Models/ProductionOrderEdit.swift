//
//  ProductionOrderEdit.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

@Model
class ProductionOrderEdit {
    
    var editedAt: Date
    var changeDescription: String
    
    @Relationship var order: ProductionOrder
    
    init(editedAt: Date = .now, changeDescription: String, order: ProductionOrder) {
        self.editedAt = editedAt
        self.changeDescription = changeDescription
        self.order = order
    }
    
}
