//
//  AddIngredientViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/20/26.
//

import SwiftData
import SwiftUI

@Observable
class AddIngredientViewModel {
    var name = ""
    var selectedUnit: Ingredient.Unit = .kg
    var customUnitLabel = ""
    var reorderLevel = ""

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (selectedUnit != .custom || !customUnitLabel.trimmingCharacters(in: .whitespaces).isEmpty) &&
        Double(reorderLevel) != nil
    }

    func save(context: ModelContext) {
        guard let reorderDouble = Double(reorderLevel) else { return }

        let ingredient = Ingredient(
            name: name.trimmingCharacters(in: .whitespaces),
            unit: selectedUnit,
            reorderLevel: reorderDouble
        )

        if selectedUnit == .custom {
            ingredient.customUnitLabel = customUnitLabel.trimmingCharacters(in: .whitespaces)
        }

        context.insert(ingredient)
    }
}
