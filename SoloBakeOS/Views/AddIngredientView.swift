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
                        viewModel.save(context: context)
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
    }
}

#Preview {
    AddIngredientView()
        .modelContainer(PreviewData.previewContainer)
}
