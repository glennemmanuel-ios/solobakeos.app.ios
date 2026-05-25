//
//  RecipeVersionHistoryView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/25/26.
//

import SwiftUI
import SwiftData

struct RecipeVersionHistoryView: View {
    let recipe: BreadRecipe

    @Query private var allRecipes: [BreadRecipe]

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }

    /// All versions of this recipe group, newest first
    private var versions: [BreadRecipe] {
        allRecipes
            .filter { $0.recipeGroupID == recipe.recipeGroupID }
            .sorted { $0.version > $1.version }
    }

    var body: some View {
        List(versions) { version in
            Section {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("v\(version.version)")
                                .font(.headline)
                            if version.isCurrentVersion {
                                Text("Current")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundStyle(.green)
                                    .clipShape(Capsule())
                            } else {
                                Text("Archived")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.15))
                                    .foregroundStyle(.secondary)
                                    .clipShape(Capsule())
                            }
                        }
                        Text("Yield: \(version.yieldLabel)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // COG per unit for this version
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(version.costPerUnit.formatted(.currency(code: currencyCode)))
                            .font(.subheadline)
                            .bold()
                        Text("COG \(version.perUnitLabel)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)

                // Ingredient composition
                ForEach(version.recipeIngredients.sorted(by: { $0.ingredient.name < $1.ingredient.name })) { ri in
                    HStack {
                        Text(ri.ingredient.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        let unit = ri.ingredient.unit == .custom
                            ? ri.ingredient.customUnitLabel ?? "units"
                            : ri.ingredient.unit.rawValue
                        Text(String(format: "%.3f %@", ri.quantity, unit))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Version History")
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if versions.isEmpty {
                ContentUnavailableView(
                    "No Versions",
                    systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                    description: Text("No version history found for this recipe.")
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeVersionHistoryView(recipe: PreviewData.pandesal)
    }
    .modelContainer(PreviewData.previewContainer)
}
