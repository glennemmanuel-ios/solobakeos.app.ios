//
//  OrderListView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/3/26.
//

import SwiftUI
import SwiftData

struct OrderListView: View {
    @Query private var orders: [ProductionOrder]
    @State private var viewModel = ViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    private var grouped: [(date: Date, orders: [ProductionOrder])] {
        viewModel.grouped(orders)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.date) { group in
                    Section(header: Text(group.date.formatted(date: .complete, time: .omitted))) {
                        ForEach(group.orders) { order in
                            NavigationLink(destination: Text("Order Detail — Step 4")) {
                                OrderRowView(order: order, vm: viewModel, currencyCode: currencyCode)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Orders")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showCreateOrder = true
                    } label: {
                        Label("New Order", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Toggle(isOn: $viewModel.showVoided) {
                        Label("Show Voided", systemImage: "eye")
                    }
                }
            }
            .overlay {
                if grouped.isEmpty {
                    ContentUnavailableView(
                        "No Orders",
                        systemImage: "list.bullet.clipboard",
                        description: Text(viewModel.showVoided
                            ? "No orders found."
                            : "No active orders. Tap + to create one.")
                    )
                }
            }
            .sheet(isPresented: $viewModel.showCreateOrder) {
                CreateOrderView()
            }
        }
    }
}

// MARK: - Order Row

private struct OrderRowView: View {
    let order: ProductionOrder
    let vm: OrderListView.ViewModel
    let currencyCode: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Recipe names summary
                Text(order.items.map { $0.recipe.name }.joined(separator: ", "))
                    .font(.headline)
                    .strikethrough(order.status == .voided)
                    .foregroundStyle(order.status == .voided ? .secondary : .primary)
                    .lineLimit(2)

                // Item count
                Text("\(order.items.count) recipe\(order.items.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if order.hasStockShortage && order.status == .confirmed {
                    Label("Stock shortage", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(vm.statusLabel(order.status))
                    .font(.caption2)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(vm.statusColor(order.status).opacity(0.15))
                    .foregroundStyle(vm.statusColor(order.status))
                    .clipShape(Capsule())

                if order.status == .confirmed {
                    Text(order.totalCostAtConfirmation.formatted(.currency(code: currencyCode)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(order.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OrderListView()
        .modelContainer(PreviewData.previewContainer)
}
