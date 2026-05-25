//
//  AddRecipeView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/25/26.
//

import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var allIngredients: [Ingredient]
    @State private var viewModel = ViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Basic Info
                Section("Recipe Details") {
                    TextField("Recipe Name", text: $viewModel.name)

                    Picker("Yield Unit", selection: $viewModel.yieldUnit) {
                        ForEach(BreadRecipe.YieldUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }

                    if viewModel.yieldUnit == .custom {
                        TextField("Custom label (e.g. batch)", text: $viewModel.customYieldLabel)
                    }

                    HStack {
                        TextField("Yield Amount", text: $viewModel.yieldAmount)
                            .keyboardType(.numberPad)
                        Text(viewModel.yieldUnit == .custom ? viewModel.customYieldLabel.isEmpty ? "units" : viewModel.customYieldLabel : viewModel.yieldUnit.rawValue)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: Initial Selling Price
                Section("Selling Price") {
                    HStack {
                        Text(currencyCode)
                            .foregroundStyle(.secondary)
                        TextField("Selling price per \(viewModel.yieldUnit == .custom ? viewModel.customYieldLabel.isEmpty ? "unit" : viewModel.customYieldLabel : viewModel.yieldUnit.rawValue)", text: $viewModel.initialSellingPrice)
                            .keyboardType(.decimalPad)
                    }
                }

                // MARK: Ingredients
                Section {
                    ForEach(viewModel.ingredientRows.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.ingredientRows[index].ingredient.name)
                                    .font(.subheadline)
                                Text(viewModel.ingredientRows[index].ingredient.unit.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            TextField("Qty", text: $viewModel.ingredientRows[index].quantity)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)

                            Text(viewModel.ingredientRows[index].ingredient.unit.rawValue)
                                .foregroundStyle(.secondary)
                                .frame(width: 30)
                        }
                    }
                    .onDelete { offsets in
                        viewModel.removeIngredient(at: offsets)
                    }

                    Button {
                        viewModel.showIngredientPicker = true
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Ingredients")
                } footer: {
                    if viewModel.ingredientRows.isEmpty {
                        Text("Add at least one ingredient.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Recipe")
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
            .sheet(isPresented: $viewModel.showIngredientPicker) {
                IngredientPickerSheet(
                    allIngredients: allIngredients,
                    alreadyAdded: viewModel.ingredientRows.map(\.ingredient),
                    onSelect: { viewModel.addIngredient($0) }
                )
            }
        }
    }
}

// MARK: - Ingredient Picker Sheet

private struct IngredientPickerSheet: View {
    let allIngredients: [Ingredient]
    let alreadyAdded: [Ingredient]
    let onSelect: (Ingredient) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filtered: [Ingredient] {
        let available = allIngredients.filter { ingredient in
            !alreadyAdded.contains(where: { $0.persistentModelID == ingredient.persistentModelID })
        }
        guard !searchText.isEmpty else { return available }
        return available.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { ingredient in
                Button {
                    onSelect(ingredient)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name)
                                .foregroundStyle(.primary)
                            Text(ingredient.unit.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.2f \(ingredient.unit.rawValue)", ingredient.currentStock))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search ingredients")
            .navigationTitle("Select Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "No Ingredients",
                        systemImage: "shippingbox",
                        description: Text("All ingredients have been added, or none exist yet.")
                    )
                }
            }
        }
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(PreviewData.previewContainer)
}
