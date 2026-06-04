//
//  IngredientListViewModel.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/20/26.
//

import Foundation
import SwiftUI

extension IngredientListView {
    
    @Observable
    class ViewModel {
        
        var searchText = ""

        func filtered(_ ingredients: [Ingredient]) -> [Ingredient] {
            guard !searchText.isEmpty else { return ingredients }
            return ingredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        func formattedWeightedAverageCost(ingredient: Ingredient) -> String {
            let currencyCode = Locale.currencyCode
            let formattedWAC = ingredient.weightedAverageCost.formatted(.currency(code: currencyCode))
            return formattedWAC
        }
        
    }
    
    
}
