# SoloBakeOS — App Plan

## Overview
SwiftUI + SwiftData bakery management app with a WAC-based inventory ledger, recipe versioning, and separated price history tracking. Seven models deliver full historical accuracy for costs, composition, and pricing. iCloud/CloudKit backs up all data. Universal app (iPad-first, iPhone supported).

---

## Features
- Production orders for daily bread production
- Ingredient inventory with WAC (Weighted Average Cost)
- Bread recipe costing with market alignment indicators
- Automatic inventory deduction on production order confirmation
- Full audit history for orders and recipe changes
- iCloud/CloudKit sync for data backup

---

## Data Models

### `Ingredient`
- `name: String`
- `unit: IngredientUnit` (enum: g, kg, ml, L, pcs, tsp, tbsp, `.custom(String)`)
- `reorderLevel: Double`
- Computed `currentStock: Double` = Σ `InventoryTransaction.quantity`
- Computed `weightedAverageCost: Double` = Σ(qty_in × unitCost) / Σ(qty_in)
- On creation: immediately prompt for opening stock entry to seed WAC

### `InventoryTransaction`
- `date: Date`
- `quantity: Double` (+ for stock-in, − for deductions)
- `unitCost: Double?` (set on stock-in; WAC snapshot set on deductions)
- `reason: TransactionReason` (enum: `openingStock`, `manualAdjustment`, `productionOrderConfirmed`, `productionOrderEdited`, `productionOrderVoided`)
- `note: String?`
- `@Relationship` to `Ingredient`

### `BreadRecipe`
- `name: String`
- `version: Int`
- `isCurrentVersion: Bool`
- `recipeGroupID: UUID` (links all versions of the same recipe)
- `@Relationship(deleteRule: .cascade)` to `[RecipeIngredient]`
- Editing ingredient composition → archives current version, forks a new one
- Editing selling price → does NOT fork; only appends `RecipePriceHistory`

### `RecipeIngredient`
- `quantity: Double`
- `@Relationship` to `Ingredient`
- `@Relationship` to `BreadRecipe`

### `RecipePriceHistory`
- `date: Date`
- `sellingPrice: Double`
- `recipeGroupID: UUID`
- Append-only; enables price-vs-cost trend analytics

### `ProductionOrder`
- `date: Date`
- `status: OrderStatus` (enum: draft, confirmed, voided)
- `quantityToBake: Int`
- `committedQuantity: Int` (snapshot of last confirmed quantity for reversal delta)
- `hasStockShortage: Bool`
- `totalCostAtConfirmation: Double`
- `@Relationship` to specific `BreadRecipe` version
- `@Relationship(deleteRule: .cascade)` to `[ProductionOrderEdit]`
- Cannot be deleted; can be edited or voided only

### `ProductionOrderEdit`
- `editedAt: Date`
- `changeDescription: String`

---

## Business Logic

### WAC Formula
`weightedAverageCost = Σ(qty_in × unitCost) / Σ(qty_in)`
Each production deduction transaction snapshots WAC at time of confirmation as `unitCost`.

### Production Order Confirm
1. Write negative `InventoryTransaction` per ingredient (with WAC snapshot as `unitCost`)
2. Store `totalCostAtConfirmation`
3. Set `committedQuantity`
4. Set `hasStockShortage` flag
5. Show non-blocking shortage summary alert (does not block confirmation)

### Production Order Edit (Confirmed)
1. Compute delta: `newQuantity - committedQuantity`
2. Write delta reversal `InventoryTransaction` records at current WAC
3. Update `committedQuantity` and `totalCostAtConfirmation`
4. Append `ProductionOrderEdit` log entry

### Production Order Void
1. Write full reversal transactions (restore all deducted stock)
2. Set status to `voided`
3. Append final `ProductionOrderEdit` entry

### Recipe Versioning
- Editing ingredient composition: archive current (`isCurrentVersion = false`), create new version with same `recipeGroupID` and incremented `version`
- Editing selling price: append `RecipePriceHistory` entry only — no version fork

### Costing Alignment Thresholds
- 🟢 Green: margin > 30%
- 🟡 Yellow: margin 15–30%
- 🔴 Red: margin < 15%

---

## Screens & Navigation

Universal app — iPad uses `NavigationSplitView` (sidebar + detail), iPhone adapts to single-column stack.

### Tabs
1. **Dashboard** — today's orders summary, low-stock alerts, top recipes by margin, costing alignment flags
2. **Inventory** — ingredient list with WAC and low-stock badges; transaction history per ingredient
3. **Recipes** — current version recipes with margin badges; version history and price history drill-down
4. **Orders** — production orders grouped by date; "Show Voided" toggle (hidden by default)

---

## iCloud Setup
- `ModelConfiguration` with `cloudKitContainerIdentifier`
- All 7 models registered in `Schema`
- iCloud + CloudKit capability in `SoloBakeOS.entitlements`

---

## Implementation Roadmap

### Session 1 — Data Foundation
*Goal: All models compile and app runs (even if blank)*
1. Delete `Item.swift`, clear all `Item` references
2. Create `Ingredient.swift` + `InventoryTransaction` model
3. Create `BreadRecipe.swift` + `RecipeIngredient` + `RecipePriceHistory` models
4. Create `ProductionOrder.swift` + `ProductionOrderEdit` model
5. Update `SoloBakeOSApp.swift` — register all 7 models, add CloudKit container ID
6. Update `SoloBakeOS.entitlements` — enable iCloud + CloudKit
7. Placeholder `ContentView.swift` — confirm app builds and runs

### Session 2 — Seed Data & Model Logic
*Goal: Core computed properties and business logic work before any real UI*
1. Implement `Ingredient.currentStock` computed property
2. Implement `Ingredient.weightedAverageCost` computed property
3. Implement `BreadRecipe.costOfGoods(quantity:)` method
4. Implement `BreadRecipe.currentSellingPrice` (latest `RecipePriceHistory`)
5. Implement `BreadRecipe.profitMargin(quantity:)` computed property
6. Write in-memory seed data preview to verify computed values

### Session 3 — Ingredient Inventory Screens
*Goal: Full ingredient management works end-to-end*
1. Build Tab shell in `ContentView.swift` with 4 placeholder tabs
2. Build `IngredientListView` — list with stock, WAC, low-stock badge
3. Build `AddIngredientView` — name, unit, reorder level form
4. Build `OpeningStockSheet` — qty + unit cost, writes `.openingStock` transaction
5. Build `IngredientDetailView` — stock-in form, manual adjustment, transaction history
6. Wire into Inventory tab

### Session 4 — Recipe & Costing Screens
*Goal: Full recipe management with live costing and price history*
1. Build `RecipeListView` — current versions only, margin badge
2. Build `AddRecipeView` — name, initial selling price, ingredient picker
3. Build `RecipeDetailView` — cost-of-goods, margin, green/yellow/red indicator
4. Build recipe composition editing — archives old version, forks new
5. Build selling price editing — appends `RecipePriceHistory` only
6. Build `RecipeVersionHistoryView`
7. Build `RecipePriceHistoryView`

### Session 5 — Production Order Screens
*Goal: Full order lifecycle — create, confirm, edit, void*
1. Build `OrderListView` — grouped by date, status badges, "Show Voided" toggle
2. Build `CreateOrderView` — recipe picker, quantity, per-ingredient shortage preview
3. Build confirm logic — deduction transactions, WAC snapshot, shortage alert
4. Build `OrderDetailView` — recipe version snapshot, cost at confirmation, edit history
5. Build order edit flow — delta reversal transactions, log entry
6. Build void flow — full reversal, final log entry

### Session 6 — Dashboard & Polish
*Goal: App feels complete and production-ready*
1. Build `DashboardView` — today's orders, low-stock alerts, top recipes by margin, costing flags
2. Polish navigation — back buttons, empty states for all lists
3. Polish forms — input validation, keyboard dismissal
4. Test iCloud sync on two devices
5. Final app icon and accent color

---

## Pacing Tips
- Sessions 1–2 are mentally heavy (pure logic, no visual reward) — do together if possible, they're shorter
- Sessions 3–5 are the most satisfying — save for when you have energy
- Each individual screen within a session is a safe stopping point

---

## Future Considerations (v2)
- **Insights tab** — margin trends over time, ingredient cost inflation, best/worst performing products (data already being captured)
- **WAC upgrade path** — already implemented in v1
- **Recipe price analytics** — `RecipePriceHistory` already captured, just needs a chart view
