//
//  BreadRecipe.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/19/26.
//

import Foundation
import SwiftData

@Model
class BreadRecipe {

    var name: String
    var version: Int
    var isCurrentVersion: Bool
    var recipeGroupID: UUID
    var yield: Int
    var yieldUnit: YieldUnit
    var customYieldLabel: String?  // used when yieldUnit == .custom

    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
    var recipeIngredients: [RecipeIngredient] = []

    init(
        name: String,
        version: Int = 1,
        isCurrentVersion: Bool = true,
        recipeGroupID: UUID = UUID(),
        yield: Int,
        yieldUnit: YieldUnit = .pieces
    ) {
        self.name = name
        self.version = version
        self.isCurrentVersion = isCurrentVersion
        self.recipeGroupID = recipeGroupID
        self.yield = yield
        self.yieldUnit = yieldUnit
    }

}

// MARK: - Yield Unit

extension BreadRecipe {

    enum YieldUnit: String, Codable, CaseIterable {
        case pieces = "pcs"
        case tray   = "tray"
        case dozen  = "dozen"
        case loaf   = "loaf"
        case pack   = "pack"
        case custom = "custom"
    }

}

// MARK: - Computed Display

extension BreadRecipe {

    /// e.g. "24 pcs", "1 tray", "2 loaves"
    var yieldLabel: String {
        let unit = yieldUnit == .custom ? (customYieldLabel ?? "units") : yieldUnit.rawValue
        return "\(yield) \(unit)"
    }

    /// e.g. "per pc", "per tray"
    var perUnitLabel: String {
        if yieldUnit == .custom { return "per \(customYieldLabel ?? "unit")" }
        switch yieldUnit {
        case .pieces: return "per pc"
        case .tray:   return "per tray"
        case .dozen:  return "per dozen"
        case .loaf:   return "per loaf"
        case .pack:   return "per pack"
        case .custom: return "per unit"
        }
    }

}

// MARK: - Helper Functions

extension BreadRecipe {
    
    /// Raw ingredient cost for one full batch. Single loop, everything derives from this.
    var rawBatchCost: Double {
        recipeIngredients.reduce(0.0) { total, item in
            total + ceil(item.quantity * item.ingredient.weightedAverageCost)
        }
    }
    
    /// Overhead applied on top of raw cost per unit (40%)
    var overheadMarginCost: Double {
        let costPerUnit = ceil(rawBatchCost / Double(yield))
        return ceil(costPerUnit * 0.4)
    }
    
    /// Final COG per unit including overhead
    var costPerUnit: Double {
        ceil(rawBatchCost / Double(yield)) + overheadMarginCost
    }
    
    /// COG for a given quantity — used for margin calc and order costing
    func costOfGoods(quantity: Int) -> Double {
        costPerUnit * Double(quantity)
    }

    func currentSellingPrice(from priceHistories: [RecipePriceHistory]) -> Double? {
        priceHistories
            .filter { $0.recipeGroupID == recipeGroupID }
            .sorted { $0.date > $1.date }
            .first?
            .sellingPrice
    }

    func profitMargin(quantity: Int, from priceHistories: [RecipePriceHistory]) -> Double? {
        guard let price = currentSellingPrice(from: priceHistories) else { return nil }
        let revenue = price * Double(quantity)
        guard revenue > 0 else { return nil }
        let cost = costOfGoods(quantity: quantity)
        return ((revenue - cost) / revenue) * 100
    }

}

// MARK: - Margin Status

extension BreadRecipe {

    enum MarginStatus: Codable {
        case good       // > 30% 🟢
        case warning    // 15–30% 🟡
        case critical   // < 15% 🔴
    }

    func marginStatus(quantity: Int, from priceHistories: [RecipePriceHistory]) -> MarginStatus? {
        guard let margin = profitMargin(quantity: quantity, from: priceHistories) else { return nil }
        switch margin {
        case 30...:   return .good
        case 15..<30: return .warning
        default:      return .critical
        }
    }

}
