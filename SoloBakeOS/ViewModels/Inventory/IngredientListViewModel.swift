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
        
        func formattedWeightedAverageCost(ingredient: Ingredient) -> String {
            let currencyCode = Locale.current.currency?.identifier ?? "PHP"
            let formattedWAC = ingredient.weightedAverageCost.formatted(.currency(code: currencyCode))
            return formattedWAC
        }
        
    }
    
    
}
