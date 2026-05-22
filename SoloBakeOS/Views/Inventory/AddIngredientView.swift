//
//  AddIngredientView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/20/26.
//

import SwiftUI
import SwiftData

struct AddIngredientView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddIngredientViewModel()
    @State private var newIngredient: Ingredient?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $viewModel.name)

                    Picker("Unit", selection: $viewModel.selectedUnit) {
                        ForEach(Ingredient.Unit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }

                    if viewModel.selectedUnit == .custom {
                        TextField("Custom unit label (e.g. bags)", text: $viewModel.customUnitLabel)
                    }
                }

                Section("Stock Settings") {
                    TextField("Reorder Level", text: $viewModel.reorderLevel)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let ingredient = viewModel.save(context: context)
                        newIngredient = ingredient
                    }
                    .disabled(!viewModel.isFormValid)
                    .sheet(item: $newIngredient) { ingredient in
                        OpeningStockSheet(ingredient: ingredient)
                            .interactiveDismissDisabled()
                    }
                }
            }
        }
        .onChange(of: newIngredient) { _, newValue in
            if newValue == nil { dismiss() }
        }
    }
}

#Preview {
    AddIngredientView()
        .modelContainer(PreviewData.previewContainer)
}
