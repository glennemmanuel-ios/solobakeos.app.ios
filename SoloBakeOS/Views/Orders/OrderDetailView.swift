//
//  OrderDetailView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/4/26.
//

import SwiftUI
import SwiftData

struct OrderDetailView: View {
    let order: ProductionOrder

    @Environment(\.modelContext) private var context
    @State private var viewModel = ViewModel()

    private var sortedEditHistory: [ProductionOrderEdit] {
        order.editHistory.sorted { $0.editedAt > $1.editedAt }
    }

    var body: some View {
        List {

            // MARK: - Status Banner
            Section {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.statusIcon(order.status))
                        .font(.largeTitle)
                        .foregroundStyle(viewModel.statusColor(order.status))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.statusLabel(order.status))
                            .font(.headline)
                            .foregroundStyle(viewModel.statusColor(order.status))
                        Text(order.date.formatted(date: .complete, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if order.hasStockShortage {
                            Label("Confirmed with stock shortage", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }

                    Spacer()

                    if order.status == .confirmed {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(order.totalCostAtConfirmation.formatted(.currency(code: Locale.currencyCode)))
                                .font(.title3)
                                .bold()
                            Text("Total Cost")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 6)
            }

            // MARK: - Actions
            if order.status != .voided {
                Section("Actions") {
                    if order.status == .draft {
                        Button {
                            let shortages = ProductionOrderService.confirm(order, context: context)
                            if !shortages.isEmpty {
                                viewModel.pendingShortages = shortages
                                viewModel.showShortageAlert = true
                            }
                        } label: {
                            Label("Confirm Order", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }

                    if order.status == .confirmed {
                        Button {
                            viewModel.prepareEdit(from: order)
                            viewModel.showEditOrder = true
                        } label: {
                            Label("Edit Order", systemImage: "pencil.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }

                    Button(role: .destructive) {
                        viewModel.showVoidConfirmation = true
                    } label: {
                        Label("Void Order", systemImage: "xmark.circle.fill")
                    }
                }
            }

            // MARK: - Order Items
            Section("Recipes") {
                ForEach(order.items) { item in
                    OrderItemRowView(item: item, currencyCode: Locale.currencyCode)
                }
            }

            // MARK: - Edit History
            if !order.editHistory.isEmpty {
                Section("Edit History") {
                    ForEach(sortedEditHistory) { edit in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(edit.changeDescription)
                                .font(.subheadline)
                            Text(edit.editedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Order Detail")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showEditOrder) {
            EditOrderView(order: order, editQuantities: $viewModel.editQuantities)
                .onDisappear {
                    // Only save if user confirmed inside the sheet
                }
        }
        .confirmationDialog(
            "Void this order?",
            isPresented: $viewModel.showVoidConfirmation,
            titleVisibility: .visible
        ) {
            Button("Void Order", role: .destructive) {
                ProductionOrderService.void(order, context: context)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("All stock deductions will be reversed. This cannot be undone.")
        }
        .alert("Confirmed with Shortages", isPresented: $viewModel.showShortageAlert) {
            Button("OK") { viewModel.pendingShortages = [] }
        } message: {
            let lines = viewModel.pendingShortages.map {
                "\($0.ingredientName): need \(String(format: "%.3f", $0.required)) \($0.unit), short \(String(format: "%.3f", $0.shortage))"
            }.joined(separator: "\n")
            Text(lines)
        }
    }
}

// MARK: - Order Item Row

private struct OrderItemRowView: View {
    let item: ProductionOrderItem
    let currencyCode: String

    private var recipe: BreadRecipe { item.recipe }

    private var itemCost: Double {
        recipe.recipeIngredients.reduce(0.0) { total, ri in
            total + (ri.quantity * Double(item.committedQuantity > 0 ? item.committedQuantity : item.quantityToBake) * ri.ingredient.weightedAverageCost)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(recipe.name)
                        .font(.headline)
                    Text("v\(recipe.version)")
                        .font(.caption2)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(Capsule())
                        .foregroundStyle(.secondary)
                }

                Text("\(item.quantityToBake) \(recipe.yieldUnit.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if item.committedQuantity > 0 && item.committedQuantity != item.quantityToBake {
                    Text("Committed: \(item.committedQuantity) \(recipe.yieldUnit.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(ceil(itemCost).formatted(.currency(code: currencyCode)))
                    .font(.subheadline)
                    .bold()
                Text("est. cost")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
