//
//  SoloBakeOSApp.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/18/26.
//

import SwiftUI
import SwiftData

@main
struct SoloBakeOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Ingredient.self,
            InventoryTransaction.self,
            BreadRecipe.self,
            RecipeIngredient.self,
            RecipePriceHistory.self,
            ProductionOrder.self,
            ProductionOrderEdit.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
