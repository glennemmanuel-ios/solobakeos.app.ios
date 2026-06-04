//
//  CreateOrderView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/3/26.
//

import SwiftUI
import SwiftData

struct CreateOrderView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var currentRecipes: [BreadRecipe]
    @State private var viewModel = ViewModel()

    private var filteredRecipes: [BreadRecipe] {
        currentRecipes.filter { $0.isCurrentVersion }
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Recipe Rows
                Section {
                    ForEach(viewModel.orderRows.indices, id: \.self) { index in
                        OrderRowFormItem(
                            row: $viewModel.orderRows[index],
                            shortages: viewModel.shortagePreview(
                                for: viewModel.orderRows[index].recipe,
                                quantity: Int(viewModel.orderRows[index].quantity) ?? 0
                            )
                        )
                    }
                    .onDelete { viewModel.removeRow(at: $0) }

                    Button {
                        viewModel.showRecipePicker = true
                    } label: {
                        Label("Add Recipe", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Recipes to Bake")
                } footer: {
                    if viewModel.orderRows.isEmpty {
                        Text("Add at least one recipe.")
                            .foregroundStyle(.red)
                    }
                }

                // MARK: Shortage Summary
                let allShortages = viewModel.orderRows.flatMap { row -> [IngredientShortage] in
                    guard let qty = Int(row.quantity) else { return [] }
                    return viewModel.shortagePreview(for: row.recipe, quantity: qty)
                }

                if !allShortages.isEmpty {
                    Section {
                        ForEach(allShortages) { shortage in
                            ShortageRowView(shortage: shortage)
                        }
                    } header: {
                        Label("Stock Shortages", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    } footer: {
                        Text("Shortages are non-blocking. You can still save and confirm this order.")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Order")
            .navigationBarTitleDisplayMode(.inline)
            .withKeyboardDoneButton()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Draft") {
                        viewModel.saveAsDraft(context: context)
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .sheet(isPresented: $viewModel.showRecipePicker) {
                RecipePickerSheet(
                    recipes: filteredRecipes,
                    alreadyAdded: viewModel.alreadyAdded,
                    onSelect: { viewModel.addRecipe($0) }
                )
            }
        }
    }
}

// MARK: - Order Row Form Item

private struct OrderRowFormItem: View {
    @Binding var row: (recipe: BreadRecipe, quantity: String)
    let shortages: [CreateOrderView.IngredientShortage]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.recipe.name)
                        .font(.headline)
                    Text("v\(row.recipe.version) · \(row.recipe.yieldLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                TextField("Qty", text: $row.quantity)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                Text(row.recipe.yieldUnit.rawValue)
                    .foregroundStyle(.secondary)
            }

            if !shortages.isEmpty {
                Label("\(shortages.count) ingredient\(shortages.count == 1 ? "" : "s") short", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Shortage Row

private struct ShortageRowView: View {
    let shortage: CreateOrderView.IngredientShortage

    var body: some View {
        HStack {
            Text(shortage.ingredientName)
                .font(.subheadline)
                .foregroundStyle(.red)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "Need %.3f %@", shortage.required, shortage.unit))
                    .font(.caption)
                Text(String(format: "Short %.3f %@", shortage.shortage, shortage.unit))
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Recipe Picker Sheet

private struct RecipePickerSheet: View {
    let recipes: [BreadRecipe]
    let alreadyAdded: [BreadRecipe]
    let onSelect: (BreadRecipe) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filtered: [BreadRecipe] {
        let available = recipes.filter { recipe in
            !alreadyAdded.contains(where: { $0.persistentModelID == recipe.persistentModelID })
        }
        guard !searchText.isEmpty else { return available }
        return available.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { recipe in
                Button {
                    onSelect(recipe)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(recipe.name).foregroundStyle(.primary)
                            Text("v\(recipe.version) · \(recipe.yieldLabel)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search recipes")
            .navigationTitle("Select Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "book",
                        description: Text(alreadyAdded.isEmpty
                            ? "No recipes found. Add one in the Recipes tab."
                            : "All available recipes have been added.")
                    )
                }
            }
        }
    }
}

#Preview {
    CreateOrderView()
        .modelContainer(PreviewData.previewContainer)
}
