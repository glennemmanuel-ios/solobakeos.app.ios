//
//  EditCompositionView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/25/26.
//

import SwiftUI
import SwiftData

struct EditCompositionView: View {
    let recipe: BreadRecipe

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var allIngredients: [Ingredient]

    @State private var viewModel: ViewModel

    init(recipe: BreadRecipe) {
        self.recipe = recipe
        let rows = recipe.recipeIngredients.map { ri in
            (ingredient: ri.ingredient, quantity: String(ri.quantity))
        }
        _viewModel = State(initialValue: ViewModel(ingredientRows: rows))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Saving will **archive v\(recipe.version)** and create **v\(recipe.version + 1)**. Price history is carried over unchanged.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

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
                    .onDelete { viewModel.removeIngredient(at: $0) }

                    Button {
                        viewModel.showIngredientPicker = true
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Ingredients")
                } footer: {
                    if viewModel.ingredientRows.isEmpty {
                        Text("At least one ingredient is required.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Composition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save New Version") {
                        viewModel.saveNewVersion(from: recipe, context: context)
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

// MARK: - ViewModel

extension EditCompositionView {

    @Observable
    class ViewModel {
        var ingredientRows: [(ingredient: Ingredient, quantity: String)]
        var showIngredientPicker = false

        init(ingredientRows: [(ingredient: Ingredient, quantity: String)] = []) {
            self.ingredientRows = ingredientRows
        }

        var isFormValid: Bool {
            !ingredientRows.isEmpty &&
            ingredientRows.allSatisfy {
                if let qty = Double($0.quantity) { return qty > 0 }
                return false
            }
        }

        func addIngredient(_ ingredient: Ingredient) {
            guard !ingredientRows.contains(where: {
                $0.ingredient.persistentModelID == ingredient.persistentModelID
            }) else { return }
            ingredientRows.append((ingredient: ingredient, quantity: ""))
        }

        func removeIngredient(at offsets: IndexSet) {
            ingredientRows.remove(atOffsets: offsets)
        }

        func saveNewVersion(from current: BreadRecipe, context: ModelContext) {
            // 1. Archive current version
            current.isCurrentVersion = false

            // 2. Fork new version — same recipeGroupID keeps price history linked
            let newRecipe = BreadRecipe(
                name: current.name,
                version: current.version + 1,
                isCurrentVersion: true,
                recipeGroupID: current.recipeGroupID,
                yield: current.yield,
                yieldUnit: current.yieldUnit
            )
            newRecipe.customYieldLabel = current.customYieldLabel

            // 3. Write new ingredient composition
            for row in ingredientRows {
                guard let qty = Double(row.quantity) else { continue }
                let ri = RecipeIngredient(quantity: qty, ingredient: row.ingredient, recipe: newRecipe)
                context.insert(ri)
            }

            context.insert(newRecipe)
            try? context.save()
        }
    }
}

#Preview {
    EditCompositionView(recipe: PreviewData.pandesal)
        .modelContainer(PreviewData.previewContainer)
}
