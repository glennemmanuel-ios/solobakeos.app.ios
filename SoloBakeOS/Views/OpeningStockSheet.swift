//
//  OpeningStockSheet.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/21/26.
//

import SwiftUI
import SwiftData

struct OpeningStockSheet: View {
    let ingredient: Ingredient

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Set the opening stock for **\(ingredient.name)**. This seeds the initial Weighted Average Cost.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Opening Stock") {
                    HStack {
                        TextField("Quantity", text: $viewModel.quantity)
                            .keyboardType(.decimalPad)
                        Text(ingredient.unit == .custom ? ingredient.customUnitLabel ?? "units" : ingredient.unit.rawValue)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text(currencyCode)
                            .foregroundStyle(.secondary)
                        TextField("Unit Cost", text: $viewModel.unitCost)
                            .keyboardType(.decimalPad)
                        Text("per \(ingredient.unit == .custom ? ingredient.customUnitLabel ?? "unit" : ingredient.unit.rawValue)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Note (optional)") {
                    TextField("e.g. Initial stock from supplier", text: $viewModel.note)
                }
            }
            .navigationTitle("Opening Stock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(for: ingredient, context: context)
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
    }
}
