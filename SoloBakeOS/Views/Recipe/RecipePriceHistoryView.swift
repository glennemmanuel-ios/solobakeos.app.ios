//
//  RecipePriceHistoryView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/25/26.
//

import SwiftUI
import SwiftData

struct RecipePriceHistoryView: View {
    let recipe: BreadRecipe

    @Query private var allPriceHistories: [RecipePriceHistory]

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    /// All price entries for this recipe group, newest first
    private var priceHistories: [RecipePriceHistory] {
        allPriceHistories
            .filter { $0.recipeGroupID == recipe.recipeGroupID }
            .sorted { $0.date > $1.date }
    }

    private var currentCOG: Double {
        recipe.costPerUnit
    }

    var body: some View {
        List {

            // MARK: - Current COG Reference
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current COG")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("v\(recipe.version) · \(recipe.yieldLabel)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Text(currentCOG.formatted(.currency(code: currencyCode)))
                        .font(.headline)
                        .bold()
                }
                .padding(.vertical, 4)
            } header: {
                Text("Reference")
            }

            // MARK: - Price History
            Section {
                if priceHistories.isEmpty {
                    Text("No price history found.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(priceHistories.enumerated()), id: \.element.persistentModelID) { index, entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                if index == 0 {
                                    Text("Latest")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.12))
                                        .foregroundStyle(.blue)
                                        .clipShape(Capsule())
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(entry.sellingPrice.formatted(.currency(code: currencyCode)))
                                    .font(.subheadline)
                                    .bold()

                                // Margin against current COG
                                let margin = ((entry.sellingPrice - currentCOG) / entry.sellingPrice) * 100
                                Text(String(format: "%.1f%% margin", margin))
                                    .font(.caption)
                                    .foregroundStyle(marginColor(margin))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            } header: {
                Text("Price History")
            } footer: {
                Text("Margin shown against the **current** COG (v\(recipe.version)). Historical COG may have differed.")
                    .font(.caption)
            }
        }
        .navigationTitle("Price History")
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if priceHistories.isEmpty {
                ContentUnavailableView(
                    "No Price History",
                    systemImage: "tag",
                    description: Text("No selling prices have been recorded for this recipe.")
                )
            }
        }
    }

    private func marginColor(_ margin: Double) -> Color {
        switch margin {
        case 30...:   return .green
        case 15..<30: return .yellow
        default:      return .red
        }
    }
}

#Preview {
    NavigationStack {
        RecipePriceHistoryView(recipe: PreviewData.pandesal)
    }
    .modelContainer(PreviewData.previewContainer)
}
