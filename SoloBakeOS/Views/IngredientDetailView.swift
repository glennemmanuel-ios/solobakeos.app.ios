//
//  IngredientDetailView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/21/26.
//

import SwiftUI
import SwiftData

struct IngredientDetailView: View {
    let ingredient: Ingredient

    @Environment(\.modelContext) private var context
    @State private var viewModel = ViewModel()

    private var unitLabel: String {
        ingredient.unit == .custom ? ingredient.customUnitLabel ?? "units" : ingredient.unit.rawValue
    }

    var body: some View {
        List {
            // MARK: - Summary Section
            Section("Summary") {
                LabeledContent("Current Stock") {
                    Text(String(format: "%.2f \(unitLabel)", ingredient.currentStock))
                        .foregroundStyle(ingredient.currentStock <= ingredient.reorderLevel ? .red : .primary)
                }
                LabeledContent("Reorder Level") {
                    Text(String(format: "%.2f \(unitLabel)", ingredient.reorderLevel))
                }
                LabeledContent("Weighted Avg. Cost") {
                    Text("\(viewModel.formattedCurrency(ingredient.weightedAverageCost)) / \(unitLabel)")
                }
            }

            // MARK: - Actions Section
            Section("Actions") {
                Button {
                    viewModel.showStockIn = true
                } label: {
                    Label("Stock In", systemImage: "plus.circle.fill")
                        .foregroundStyle(.green)
                }

                Button {
                    viewModel.showAdjustment = true
                } label: {
                    Label("Manual Adjustment", systemImage: "pencil.circle.fill")
                        .foregroundStyle(.orange)
                }
            }

            // MARK: - Transaction History
            Section("Transaction History") {
                if ingredient.transactions.isEmpty {
                    Text("No transactions yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(ingredient.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionRowView(transaction: transaction, unitLabel: unitLabel)
                    }
                }
            }
        }
        .navigationTitle(ingredient.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showStockIn) {
            StockInSheet(ingredient: ingredient, viewModel: $viewModel)
        }
        .sheet(isPresented: $viewModel.showAdjustment) {
            AdjustmentSheet(ingredient: ingredient, viewModel: $viewModel)
        }
    }
}

// MARK: - Transaction Row

private struct TransactionRowView: View {
    let transaction: InventoryTransaction
    let unitLabel: String

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.reason.displayName)
                    .font(.subheadline)
                if let note = transaction.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%+.2f \(unitLabel)", transaction.quantity))
                    .font(.subheadline)
                    .foregroundStyle(transaction.quantity >= 0 ? .green : .red)
                if let cost = transaction.unitCost {
                    Text("\(cost.formatted(.currency(code: currencyCode))) / \(unitLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Stock In Sheet

private struct StockInSheet: View {
    let ingredient: Ingredient
    
    @Binding var viewModel: IngredientDetailView.ViewModel

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private var unitLabel: String {
        ingredient.unit == .custom ? ingredient.customUnitLabel ?? "units" : ingredient.unit.rawValue
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Stock In") {
                    HStack {
                        TextField("Quantity", text: $viewModel.stockInQuantity)
                            .keyboardType(.decimalPad)
                        Text(unitLabel)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text(Locale.current.currency?.identifier ?? "PHP")
                            .foregroundStyle(.secondary)
                        TextField("Total amount paid", text: $viewModel.totalAmountPaid)
                            .keyboardType(.decimalPad)
                    }
                    
                    if let computed = viewModel.computedUnitCost {
                        LabeledContent("Cost per \(unitLabel)") {
                            Text(computed.formatted(.currency(code: Locale.current.currency?.identifier ?? "PHP")))
                                .foregroundStyle(.green)
                                .bold()
                        }
                    }
                }

                Section("Note (optional)") {
                    TextField("e.g. Delivery from supplier", text: $viewModel.stockInNote)
                }
            }
            .navigationTitle("Stock In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveStockIn(for: ingredient, context: context)
                        dismiss()
                    }
                    .disabled(!viewModel.isStockInValid)
                }
            }
        }
    }
}

// MARK: - Adjustment Sheet

private struct AdjustmentSheet: View {
    let ingredient: Ingredient
    @Binding var viewModel: IngredientDetailView.ViewModel

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private var unitLabel: String {
        ingredient.unit == .custom ? ingredient.customUnitLabel ?? "units" : ingredient.unit.rawValue
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Enter a positive value to add stock, negative to remove (e.g. **-2.5** to correct an overcount).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Adjustment") {
                    HStack {
                        TextField("Quantity (e.g. -2.5)", text: $viewModel.adjustmentQuantity)
                            .keyboardType(.numbersAndPunctuation)
                        Text(unitLabel)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Note (optional)") {
                    TextField("e.g. Corrected after physical count", text: $viewModel.adjustmentNote)
                }
            }
            .navigationTitle("Manual Adjustment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveAdjustment(for: ingredient, context: context)
                        dismiss()
                    }
                    .disabled(!viewModel.isAdjustmentValid)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        IngredientDetailView(ingredient: PreviewData.flour)
    }
    .modelContainer(PreviewData.previewContainer)
}
