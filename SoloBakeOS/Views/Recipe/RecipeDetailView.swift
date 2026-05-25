//
//  RecipeDetailView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/25/26.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: BreadRecipe

    @Environment(\.modelContext) private var context
    @Query private var priceHistories: [RecipePriceHistory]
    @State private var viewModel = ViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    private var cog: Double {
        recipe.costOfGoods(quantity: recipe.yield)
    }
    
    private var overheadMargin: Double {
        recipe.overheadMarginCost
    }

    private var cogPerUnit: Double {
        cog / Double(recipe.yield)
    }

    private var sellingPrice: Double? {
        recipe.currentSellingPrice(from: priceHistories)
    }

    private var margin: Double? {
        recipe.profitMargin(quantity: recipe.yield, from: priceHistories)
    }

    private var marginStatus: BreadRecipe.MarginStatus? {
        recipe.marginStatus(quantity: recipe.yield, from: priceHistories)
    }

    var body: some View {
        List {

            // MARK: - Margin Summary
            Section {
                HStack(spacing: 16) {
                    // Margin indicator
                    VStack(spacing: 4) {
                        if let status = marginStatus, let margin = margin {
                            Text(viewModel.marginEmoji(status))
                                .font(.largeTitle)
                            Text(String(format: "%.1f%%", margin))
                                .font(.title2)
                                .bold()
                                .foregroundStyle(viewModel.marginColor(status))
                            Text("Margin")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("—")
                                .font(.largeTitle)
                            Text("No price set")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // COG vs Price
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("COG \(recipe.perUnitLabel)") {
                            Text(cogPerUnit.formatted(.currency(code: currencyCode)))
                                .bold()
                        }

                        LabeledContent("Selling Price") {
                            if let price = sellingPrice {
                                Text(price.formatted(.currency(code: currencyCode)))
                            } else {
                                Text("Not set")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        LabeledContent("Yield") {
                            Text(recipe.yieldLabel)
                        }

                        LabeledContent("Version") {
                            Text("v\(recipe.version)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }

            // MARK: - Actions
            Section("Manage") {
                Button {
                    viewModel.showUpdatePrice = true
                } label: {
                    Label("Update Selling Price", systemImage: "tag.fill")
                }

                Button {
                    viewModel.showEditComposition = true
                } label: {
                    Label("Edit Composition", systemImage: "pencil.and.list.clipboard")
                }

                NavigationLink(destination: RecipeVersionHistoryView(recipe: recipe)) {
                    Label("Version History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }

                NavigationLink(destination: RecipePriceHistoryView(recipe: recipe)) {
                    Label("Price History", systemImage: "chart.line.uptrend.xyaxis")
                }
            }

            // MARK: - Ingredient Composition
            Section("Ingredients") {
                let breakdown = viewModel.costBreakdown(for: recipe)
                ForEach(breakdown, id: \.name) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.subheadline)
                            Text(String(format: "%.3f %@", item.quantity, item.unit))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.cost.formatted(.currency(code: currencyCode)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                
                // Overhead cost
                HStack {
                    Text("Overhead Margin Cost")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Text(overheadMargin.formatted(.currency(code: currencyCode)))
                        .font(.subheadline)
                        .bold()
                }
                .padding(.vertical, 2)

                // Total batch cost
                HStack {
                    Text("Total Batch COG")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Text(cog.formatted(.currency(code: currencyCode)))
                        .font(.subheadline)
                        .bold()
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showUpdatePrice) {
            UpdateSellingPriceSheet(recipe: recipe, vm: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditComposition) {  // 👈 add this
            EditCompositionView(recipe: recipe)
        }
    }
}

// MARK: - Update Selling Price Sheet

private struct UpdateSellingPriceSheet: View {
    let recipe: BreadRecipe
    @Bindable var vm: RecipeDetailView.ViewModel

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("This will **not** create a new recipe version. Only the selling price history is updated.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("New Selling Price") {
                    HStack {
                        Text(currencyCode)
                            .foregroundStyle(.secondary)
                        TextField("Price \(recipe.perUnitLabel)", text: $vm.newSellingPrice)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Update Price")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.updateSellingPrice(for: recipe, context: context)
                        dismiss()
                    }
                    .disabled(!vm.isUpdatePriceValid)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: PreviewData.pandesal)
    }
    .modelContainer(PreviewData.previewContainer)
}
