//
//  AppStore.swift
//  AtelierBistro
//
//  Estado reactivo de la aplicación. Porta la lógica del prototipo:
//  catálogo, carrito con propinas, división de cuenta, comanda activa
//  con seguimiento en vivo y tablero KDS de cocina.
//

import Foundation
import SwiftUI

/// Sección de la carta. Cuando se explora «Todo» sin búsqueda, cada categoría
/// con platos se convierte en una sección con su encabezado.
struct CatalogSection: Identifiable, Hashable {
    let category: MenuCategory
    let products: [Product]
    /// `true` si la sección lleva encabezado (agrupación por categorías).
    let isGrouped: Bool

    var id: String { category.id }
}

/// Estado de configuración del plato abierto en el modal de personalización.
struct ProductConfigState: Hashable {
    var quantity: Int = 1
    /// Selección por grupo `single`: id de grupo → id de opción.
    var singleSelections: [String: String] = [:]
    /// Selección acumulada de grupos `multiple`.
    var multiSelections: [String] = []
    var kitchenNote: String = ""
}

/// Rutas presentadas como hoja. `NavigationStack` permite encadenar
/// carrito → dividir cuenta y ticket → dividir cuenta, replicando
/// el apilado de modales del prototipo.
enum AppRoute: Identifiable, Hashable {
    case productConfig(productID: String)
    case cart
    case splitBill(SplitOrigin)
    case ticket

    var id: String {
        switch self {
        case .productConfig(let productID): return "product-\(productID)"
        case .cart: return "cart"
        case .splitBill(let origin): return "split-\(origin)"
        case .ticket: return "ticket"
        }
    }
}

/// Tipo de aviso mostrado tras una operación de pago.
struct PaymentFeedback: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class AppStore: ObservableObject {

    // MARK: - Navegación de la carta

    @Published var currentCategory: String = MenuCategory.all.id
    @Published var searchQuery: String = ""

    // MARK: - Carrito y propina

    @Published private(set) var cart: [CartItem] = []
    @Published var tipMode: TipMode = .percentage(0)

    // MARK: - Comanda activa (seguimiento del comensal)

    @Published private(set) var activeOrder: KitchenOrder?

    // MARK: - División de cuenta

    @Published var splitMode: SplitMode = .equal
    @Published private(set) var splitGuests: Int = 2
    @Published private(set) var splitSelectedItems: [String] = []
    @Published private(set) var splitTablePaidTotal: Double = 0
    @Published private(set) var splitOrigin: SplitOrigin = .cart

    // MARK: - Cocina (KDS)

    @Published private(set) var kitchenOrders: [KitchenOrder]
    @Published var kdsFilter: OrderStatus?   // `nil` = todas

    // MARK: - Presentación

    /// Pila de capas modales apiladas dentro del marco del móvil.
    /// Replica el z-index del prototipo: carrito → dividir cuenta, etc.
    @Published private(set) var overlays: [AppRoute] = []
    @Published private(set) var configState = ProductConfigState()
    @Published private(set) var configProductID: String?
    @Published var feedback: PaymentFeedback?
    /// Marca para desplazar el carrito hasta la sección de propina.
    @Published var highlightTipSection = false

    // MARK: - Catálogo

    let categories = SampleData.categories
    let products = SampleData.products

    private let storageKey = "atelier_table04_active_order"

    init() {
        self.kitchenOrders = SampleData.initialKitchenOrders()
        loadActiveOrderFromStorage()
    }

    // MARK: - Acceso al catálogo

    var availableCategories: [MenuCategory] { categories }

    var selectedCategory: MenuCategory {
        categories.first { $0.id == currentCategory } ?? .all
    }

    /// Productos que cumplen categoría y búsqueda actuales.
    var filteredProducts: [Product] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return products.filter { product in
            let matchesCategory = currentCategory == MenuCategory.all.id
                || product.categoryId == currentCategory
            let matchesSearch = query.isEmpty
                || product.name.lowercased().contains(query)
                || product.description.lowercased().contains(query)
            return matchesCategory && matchesSearch
        }
    }

    /// Cuando se explora «Todo» sin búsqueda, la carta se agrupa por secciones.
    var groupedCatalog: [CatalogSection] {
        let filtered = filteredProducts
        guard currentCategory == MenuCategory.all.id, searchQuery.isEmpty else {
            return [
                CatalogSection(category: selectedCategory, products: filtered, isGrouped: false)
            ]
        }

        return categories
            .filter { $0.id != MenuCategory.all.id }
            .compactMap { category in
                let items = filtered.filter { $0.categoryId == category.id }
                guard !items.isEmpty else { return nil }
                return CatalogSection(category: category, products: items, isGrouped: true)
            }
    }

    var product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    func categoryName(for id: String) -> String {
        categories.first { $0.id == id }?.name ?? "Plato"
    }

    func setCategory(_ id: String) {
        currentCategory = id
    }

    func clearSearch() {
        searchQuery = ""
    }

    // MARK: - Configuración del plato (modal de personalización)

    var configProduct: Product? {
        configProductID.flatMap(product(for:))
    }

    /// Abre el modal de personalización con la primera opción de cada grupo
    /// obligatorio ya marcada, igual que el prototipo.
    func openProductConfig(_ productID: String) {
        guard let product = product(for: productID), product.isAvailable else { return }

        var state = ProductConfigState()
        for group in product.modifiers where group.kind == .single {
            state.singleSelections[group.id] = group.options.first?.id
        }

        configProductID = productID
        configState = state
        push(.productConfig(productID: productID))
    }

    func closeProductConfig() {
        configProductID = nil
        configState = ProductConfigState()
        pop()
    }

    // MARK: - Pila de capas modales

    /// Capa superior visible.
    var topOverlay: AppRoute? { overlays.last }

    func push(_ route: AppRoute) {
        overlays.append(route)
    }

    /// Cierra la capa superior y deja visible la inferior.
    func pop() {
        guard !overlays.isEmpty else { return }
        overlays.removeLast()
    }

    /// Cierra todas las capas (vuelve a la carta).
    func dismissAllOverlays() {
        overlays.removeAll()
    }

    /// Precio unitario con los suplementos de los modificadores elegidos.
    func configuredUnitPrice() -> Double {
        guard let product = configProduct else { return 0 }
        var total = product.price

        for group in product.modifiers {
            switch group.kind {
            case .single:
                if let optionID = configState.singleSelections[group.id],
                   let option = group.options.first(where: { $0.id == optionID }) {
                    total += option.price
                }
            case .multiple:
                for option in group.options where configState.multiSelections.contains(option.id) {
                    total += option.price
                }
            }
        }

        return total
    }

    var configRunningTotal: Double {
        configuredUnitPrice() * Double(configState.quantity)
    }

    func changeConfigQuantity(by delta: Int) {
        let next = configState.quantity + delta
        guard (1...20).contains(next) else { return }
        configState.quantity = next
    }

    func toggleModifier(groupID: String, optionID: String, kind: ModifierGroup.Kind, isSelected: Bool) {
        switch kind {
        case .single:
            configState.singleSelections[groupID] = optionID
        case .multiple:
            if isSelected {
                if !configState.multiSelections.contains(optionID) {
                    configState.multiSelections.append(optionID)
                }
            } else {
                configState.multiSelections.removeAll { $0 == optionID }
            }
        }
    }

    func setConfigNote(_ note: String) {
        configState.kitchenNote = note
    }

    /// Nombres legibles de los modificadores elegidos, en orden de grupo.
    private func selectedModifierNames(for product: Product) -> [String] {
        var names: [String] = []

        for group in product.modifiers {
            switch group.kind {
            case .single:
                if let optionID = configState.singleSelections[group.id],
                   let option = group.options.first(where: { $0.id == optionID }) {
                    names.append(option.name)
                }
            case .multiple:
                for option in group.options where configState.multiSelections.contains(option.id) {
                    names.append(option.name)
                }
            }
        }

        return names
    }

    func submitProductToCart() {
        guard let product = configProduct else { return }

        let item = CartItem(
            id: "ci-\(Int(Date().timeIntervalSince1970 * 1000))-\(Int.random(in: 0...999))",
            productId: product.id,
            name: product.name,
            unitPrice: configuredUnitPrice(),
            quantity: configState.quantity,
            modifiers: selectedModifierNames(for: product),
            note: configState.kitchenNote.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        cart.append(item)
        configProductID = nil
        configState = ProductConfigState()
        // Tras añadir, el prototipo cierra el modal y abre el resumen de comanda.
        pop()
        push(.cart)
    }

    // MARK: - Carrito

    var cartBadgeCount: Int {
        cart.reduce(0) { $0 + $1.quantity }
    }

    var isCartEmpty: Bool { cart.isEmpty }

    func removeCartItem(_ id: String) {
        cart.removeAll { $0.id == id }
    }

    /// Desglose económico del carrito aplicando la propina elegida.
    var totals: OrderTotals {
        let gross = cart.reduce(0) { $0 + $1.lineTotal }
        return OrderTotals.make(grossSubtotal: gross, tip: tipMode)
    }

    func setTipOption(_ percentage: Double) {
        tipMode = .percentage(percentage)
    }

    func setCustomTip(_ value: Double) {
        guard value >= 0 else {
            tipMode = .percentage(0)
            return
        }
        tipMode = .fixed(value)
    }

    func clearTip() {
        tipMode = .percentage(0)
    }

    /// Porcentaje marcado actualmente (o `nil` si la propina es un importe fijo).
    var selectedTipPercentage: Double? {
        if case .percentage(let value) = tipMode { return value }
        return nil
    }

    var customTipValue: Double? {
        if case .fixed(let value) = tipMode { return value }
        return nil
    }

    // MARK: - División de cuenta

    /// Fuente de datos del divisor: carrito, comanda activa o demo.
    var splitDataset: SplitDataset {
        if !cart.isEmpty {
            let totals = self.totals
            return SplitDataset(
                source: .cart,
                items: cart.map {
                    SplitLine(id: $0.id, name: $0.name, quantity: $0.quantity, totalPrice: $0.lineTotal)
                },
                subtotal: totals.grossSubtotal,
                tip: totals.tipAmount,
                grandTotal: totals.grandTotal
            )
        }

        if let order = activeOrder {
            let count = max(1, order.items.count)
            return SplitDataset(
                source: .order,
                items: order.items.map { item in
                    let unit = item.unitPrice ?? (order.effectiveSubtotal / Double(count))
                    return SplitLine(
                        id: item.id,
                        name: item.name,
                        quantity: item.quantity,
                        totalPrice: unit * Double(item.quantity)
                    )
                },
                subtotal: order.effectiveSubtotal,
                tip: order.effectiveTip,
                grandTotal: order.effectiveSubtotal + order.effectiveTip
            )
        }

        return SampleData.demoSplitDataset
    }

    var splitPerPerson: Double {
        guard splitGuests > 0 else { return 0 }
        return splitDataset.grandTotal / Double(splitGuests)
    }

    /// Aportación del comensal según el modo activo.
    var splitMyShare: Double {
        switch splitMode {
        case .equal:
            return splitPerPerson
        case .items:
            let selected = splitDataset.items
                .filter { splitSelectedItems.contains($0.id) }
                .reduce(0) { $0 + $1.totalPrice }
            return selected * (1 + splitDataset.tipProportion)
        }
    }

    var splitSelectedSubtotal: Double {
        splitDataset.items
            .filter { splitSelectedItems.contains($0.id) }
            .reduce(0) { $0 + $1.totalPrice }
    }

    var splitSelectedTip: Double {
        splitSelectedSubtotal * splitDataset.tipProportion
    }

    var splitProgress: Double {
        guard splitDataset.grandTotal > 0 else { return 0 }
        return min(1, splitTablePaidTotal / splitDataset.grandTotal)
    }

    func isGuestPaid(_ index: Int) -> Bool {
        splitTablePaidTotal >= splitPerPerson * Double(index + 1)
    }

    /// Abre el divisor apilándolo sobre la capa actual (carrito o ticket).
    func openSplitBill(origin: SplitOrigin) {
        splitOrigin = origin
        splitSelectedItems = []
        push(.splitBill(origin))
    }

    /// Al cerrar, reaparece automáticamente la capa inferior.
    func closeSplitBill() {
        pop()
    }

    func switchSplitMode(_ mode: SplitMode) {
        splitMode = mode
    }

    func changeSplitGuests(by delta: Int) {
        let next = splitGuests + delta
        guard (2...12).contains(next) else { return }
        splitGuests = next
    }

    func setSplitGuests(_ value: Int) {
        guard (2...12).contains(value) else { return }
        splitGuests = value
    }

    func toggleSplitItem(_ id: String) {
        if let index = splitSelectedItems.firstIndex(of: id) {
            splitSelectedItems.remove(at: index)
        } else {
            splitSelectedItems.append(id)
        }
    }

    func isSplitItemSelected(_ id: String) -> Bool {
        splitSelectedItems.contains(id)
    }

    func executeSharePayment() {
        let amount = splitMyShare
        guard amount > 0 else { return }

        splitTablePaidTotal = min(splitDataset.grandTotal, splitTablePaidTotal + amount)

        feedback = PaymentFeedback(
            title: "Pago registrado",
            message: "Pago de \(Money.format(amount)) procesado correctamente. Recibo digital enviado a la mesa."
        )
    }

    func executeFullPayment() {
        let total = splitDataset.grandTotal
        splitTablePaidTotal = total

        feedback = PaymentFeedback(
            title: "Cuenta liquidada",
            message: "Cuenta total de \(Money.format(total)) pagada íntegramente. Servicio cerrado para Mesa 04."
        )
    }

    // MARK: - Confirmación de comanda

    func confirmOrder() {
        guard !cart.isEmpty else { return }

        let code = "AT-\(Int.random(in: 100...999))"
        let breakdown = totals

        let order = KitchenOrder(
            id: code,
            table: "04",
            createdAt: Date(),
            status: .pending,
            notes: "",
            items: cart.map { item in
                KitchenItem(
                    name: item.name,
                    quantity: item.quantity,
                    options: item.modifiers,
                    kitchenNote: item.note,
                    unitPrice: item.unitPrice
                )
            },
            subtotal: breakdown.grossSubtotal,
            tip: breakdown.tipAmount
        )

        kitchenOrders.insert(order, at: 0)
        activeOrder = order
        saveActiveOrderToStorage()

        cart.removeAll()
        tipMode = .percentage(0)
        // Se cierra el carrito y se abre el ticket de seguimiento.
        overlays = [.ticket]
    }

    // MARK: - Comanda activa y persistencia

    var hasActiveOrder: Bool { activeOrder != nil }

    private func saveActiveOrderToStorage() {
        guard let order = activeOrder,
              let data = try? JSONEncoder().encode(order) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadActiveOrderFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let order = try? JSONDecoder().decode(KitchenOrder.self, from: data) else { return }
        activeOrder = order
    }

    /// Avanza manualmente el estado de la comanda del comensal (demo)
    /// y sincroniza el KDS.
    func advanceActiveOrderStatus() {
        guard let order = activeOrder, let next = order.status.next else { return }
        activeOrder?.status = next
        activeOrder?.createdAt = order.createdAt

        if let index = kitchenOrders.firstIndex(where: { $0.id == order.id }) {
            kitchenOrders[index].status = next
        }

        saveActiveOrderToStorage()
    }

    /// Reinicia el estado de la comanda activa a «pendiente» (demo).
    func resetActiveOrderDemo() {
        guard let order = activeOrder else { return }
        activeOrder?.status = .pending

        if let index = kitchenOrders.firstIndex(where: { $0.id == order.id }) {
            kitchenOrders[index].status = .pending
        }

        saveActiveOrderToStorage()
    }

    func openTicket() {
        guard hasActiveOrder else { return }
        push(.ticket)
    }

    func openCart() {
        push(.cart)
    }

    /// Cierra el ticket y abre el carrito, posicionando la sección de propina.
    func openTipAdjustment() {
        overlays = [.cart]
        highlightTipSection = true
    }

    // MARK: - Cocina (KDS)

    /// Comandas visibles según el filtro seleccionado.
    var filteredKitchenOrders: [KitchenOrder] {
        guard let filter = kdsFilter else { return kitchenOrders }
        return kitchenOrders.filter { $0.status == filter }
    }

    var activeKitchenCount: Int {
        kitchenOrders.filter { $0.status != .delivered }.count
    }

    func count(for status: OrderStatus) -> Int {
        kitchenOrders.filter { $0.status == status }.count
    }

    func setKdsFilter(_ status: OrderStatus?) {
        kdsFilter = status
    }

    func advanceKitchenOrder(_ id: String) {
        guard let index = kitchenOrders.firstIndex(where: { $0.id == id }),
              let next = kitchenOrders[index].status.next else { return }

        kitchenOrders[index].status = next

        if activeOrder?.id == id {
            activeOrder?.status = next
            saveActiveOrderToStorage()
        }
    }

    func archiveKitchenOrder(_ id: String) {
        kitchenOrders.removeAll { $0.id == id }
    }

    func generateRandomKitchenOrder() {
        kitchenOrders.insert(SampleData.randomKitchenOrder(), at: 0)
    }
}
