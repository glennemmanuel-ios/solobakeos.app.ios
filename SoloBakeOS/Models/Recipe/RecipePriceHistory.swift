//
//  RecipePriceHistory.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

@Model
class RecipePriceHistory {
    
    var date: Date
    var sellingPrice: Double
    var recipeGroupID: UUID
    
    init(date: Date = .now, sellingPrice: Double, recipeGroupID: UUID) {
        self.date = date
        self.sellingPrice = sellingPrice
        self.recipeGroupID = recipeGroupID
    }
    
}
