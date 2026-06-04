//
//  EditOrderView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/4/26.
//

import SwiftUI
import SwiftData

struct EditOrderView: View {
    let order: ProductionOrder
    @Binding var editQuantities: [PersistentIdentifier: String]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private var isValid: Bool {
        order.items.allSatisfy { item in
            guard let str = editQuantities[item.persistentModelID],
                  let qty = Int(str) else { return false }
            return qty > 0
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Adjusting quantities will write delta inventory transactions at the current WAC.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Quantities") {
                    ForEach(order.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.recipe.name)
                                    .font(.subheadline)
                                Text("Committed: \(item.committedQuantity) \(item.recipe.yieldUnit.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            TextField(
                                "Qty",
                                text: Binding(
                                    get: { editQuantities[item.persistentModelID] ?? String(item.committedQuantity) },
                                    set: { editQuantities[item.persistentModelID] = $0 }
                                )
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)

                            Text(item.recipe.yieldUnit.rawValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newQtys = editQuantities.compactMapValues { Int($0) }
                        ProductionOrderService.edit(order, newQuantities: newQtys, context: context)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
