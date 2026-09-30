//
//  Models.swift
//  AtelierBistro
//
//  Modelos de dominio del sistema Smart Table Order & KDS.
//  Traducción directa de la estructura de datos del prototipo HTML.
//

import Foundation

// MARK: - Catálogo de la carta

/// Categoría de la carta (barra de navegación horizontal del comensal).
struct MenuCategory: Identifiable, Hashable, Sendable {
    let id: String
    let name: String

    /// Categoría comodín que agrupa todas las secciones.
    static let all = MenuCategory(id: "all", name: "Todo")
}

/// Grupo de opciones de personalización de un plato.
struct ModifierGroup: Identifiable, Hashable, Sendable {
    enum Kind: String, Sendable {
        /// Selección única (radio). El prototipo marca la primera opción por defecto.
        case single
        /// Selección múltiple (checkbox).
        case multiple
    }

    let id: String
    let name: String
    let isRequired: Bool
    let kind: Kind
    let options: [ModifierOption]
}

/// Opción concreta dentro de un grupo de modificadores.
struct ModifierOption: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    /// Suplemento en euros. `0` se muestra como "Incluido".
    let price: Double
}

/// Plato de la carta.
struct Product: Identifiable, Hashable, Sendable {
    let id: String
    let categoryId: String
    let name: String
    let description: String
    let price: Double
    let isAvailable: Bool
    let modifiers: [ModifierGroup]
}

// MARK: - Carrito del comensal

/// Línea del carrito ya personalizada y lista para enviar a cocina.
struct CartItem: Identifiable, Hashable, Sendable {
    let id: String
    let productId: String
    let name: String
    /// Precio unitario con los suplementos ya aplicados.
    let unitPrice: Double
    let quantity: Int
    /// Nombres legibles de los modificadores elegidos.
    let modifiers: [String]
    let note: String

    var lineTotal: Double { unitPrice * Double(quantity) }
}

// MARK: - Propina

/// Modo de cálculo de la propina de servicio.
enum TipMode: Hashable, Sendable {
    /// Porcentaje sobre el subtotal (0 %, 5 %, 10 %, 15 %).
    case percentage(Double)
    /// Importe fijo en euros.
    case fixed(Double)

    var displayLabel: String {
        switch self {
        case .percentage(let value):
            // Se evita "10.0%" mostrando enteros sin decimales.
            return value == value.rounded()
                ? "\(Int(value))%"
                : String(format: "%.1f%%", value)
        case .fixed(let value):
            return Money.format(value)
        }
    }
}

// MARK: - Totales

/// Desglose económico de la comanda. El IVA (10 %) ya está incluido
/// en los precios de la carta, por lo que se extrae del subtotal bruto.
struct OrderTotals: Hashable, Sendable {
    /// Suma de las líneas tal como aparecen en la carta (IVA incluido).
    let grossSubtotal: Double
    /// Base imponible (subtotal sin IVA).
    let baseSubtotal: Double
    /// Cuota de IVA contenida en el subtotal.
    let tax: Double
    /// Propina calculada.
    let tipAmount: Double
    /// Total a pagar (subtotal bruto + propina).
    let grandTotal: Double

    static let zero = OrderTotals(
        grossSubtotal: 0, baseSubtotal: 0, tax: 0, tipAmount: 0, grandTotal: 0
    )

    /// Tipo de IVA aplicado en el prototipo (10 %).
    static let taxRate: Double = 0.10

    /// Calcula el desglose a partir del subtotal bruto y la propina elegida.
    static func make(grossSubtotal: Double, tip: TipMode) -> OrderTotals {
        guard grossSubtotal > 0 else { return .zero }

        let baseSubtotal = grossSubtotal / (1 + taxRate)
        let tax = grossSubtotal - baseSubtotal

        let tipAmount: Double
        switch tip {
        case .percentage(let value):
            tipAmount = grossSubtotal * value / 100
        case .fixed(let value):
            tipAmount = value
        }

        return OrderTotals(
            grossSubtotal: grossSubtotal,
            baseSubtotal: baseSubtotal,
            tax: tax,
            tipAmount: tipAmount,
            grandTotal: grossSubtotal + tipAmount
        )
    }
}

// MARK: - Comanda de cocina (KDS)

/// Estado del ciclo de vida de una comanda.
enum OrderStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case pending
    case inProgress = "in_progress"
    case ready
    case delivered

    /// Etiqueta corta mostrada en el pie de las tarjetas KDS.
    var shortLabel: String {
        switch self {
        case .pending: return "PENDIENTE"
        case .inProgress: return "EN COCINA"
        case .ready: return "LISTO SERVIR"
        case .delivered: return "ENTREGADO"
        }
    }

    /// Etiqueta del flujo de seguimiento del comensal.
    var customerLabel: String {
        switch self {
        case .pending: return "Recibido"
        case .inProgress: return "En cocina"
        case .ready: return "Listo para servir"
        case .delivered: return "Entregado"
        }
    }

    /// Texto del botón que avanza al siguiente estado.
    var advanceLabel: String? {
        switch self {
        case .pending: return "Empezar Preparación"
        case .inProgress: return "Marcar Listo"
        case .ready: return "Servido / Entregar"
        case .delivered: return nil
        }
    }

    /// Siguiente estado del flujo, o `nil` si ya está entregada.
    var next: OrderStatus? {
        switch self {
        case .pending: return .inProgress
        case .inProgress: return .ready
        case .ready: return .delivered
        case .delivered: return nil
        }
    }

    /// Nombre del filtro en la barra superior del KDS.
    var filterLabel: String {
        switch self {
        case .pending: return "Pendientes"
        case .inProgress: return "En Preparación"
        case .ready: return "Listas"
        case .delivered: return "Entregadas"
        }
    }
}

/// Línea de una comanda tal como la lee el cocinero.
struct KitchenItem: Identifiable, Hashable, Codable, Sendable {
    var id: String = UUID().uuidString
    let name: String
    let quantity: Int
    let options: [String]
    let kitchenNote: String
    /// Precio unitario. Opcional porque las comandas de demo no lo llevan.
    var unitPrice: Double?

    init(
        id: String = UUID().uuidString,
        name: String,
        quantity: Int,
        options: [String],
        kitchenNote: String,
        unitPrice: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.options = options
        self.kitchenNote = kitchenNote
        self.unitPrice = unitPrice
    }
}

/// Comanda completa visible en el KDS y en el ticket del comensal.
struct KitchenOrder: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let table: String
    var createdAt: Date
    var status: OrderStatus
    /// Aviso destacado (alergias, necesidades especiales).
    var notes: String
    var items: [KitchenItem]
    /// Subtotal bruto (IVA incluido). Opcional en comandas de demo.
    var subtotal: Double? = nil
    /// Propina asociada a la cuenta.
    var tip: Double? = nil

    /// Minutos transcurridos desde el envío, para los cronómetros del KDS.
    func elapsedMinutes(from now: Date = Date()) -> Int {
        max(0, Int(now.timeIntervalSince(createdAt) / 60))
    }

    /// El prototipo marca en ámbar las comandas que superan 15 minutos.
    func isDelayed(from now: Date = Date()) -> Bool {
        elapsedMinutes(from: now) >= 15
    }

    /// Subtotal con protección ante comandas sin importe.
    var effectiveSubtotal: Double { subtotal ?? total ?? 0 }
    var effectiveTip: Double { tip ?? 0 }
    var total: Double? { subtotal.map { $0 + (tip ?? 0) } }
}

// MARK: - División de cuenta

/// Modo de reparto de la cuenta.
enum SplitMode: String, CaseIterable, Hashable, Sendable {
    case equal
    case items

    var label: String {
        switch self {
        case .equal: return "Partes Iguales"
        case .items: return "Por Ítems / Consumo"
        }
    }
}

/// Ítem facturable usado por el divisor de cuenta.
struct SplitLine: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let quantity: Int
    let totalPrice: Double
}

/// Origen desde el que se abrió el divisor de cuenta.
enum SplitOrigin: Hashable, Sendable {
    case direct
    case cart
    case ticket
}

/// Conjunto de datos sobre el que opera el divisor de cuenta.
struct SplitDataset: Hashable, Sendable {
    enum Source: Hashable, Sendable {
        case cart
        case order
        /// Datos de ejemplo cuando no hay carrito ni comanda activa.
        case demo
    }

    let source: Source
    let items: [SplitLine]
    let subtotal: Double
    let tip: Double
    let grandTotal: Double

    /// Proporción de propina respecto al subtotal, para repartos por ítems.
    var tipProportion: Double {
        subtotal > 0 ? tip / subtotal : 0
    }
}

// MARK: - Utilidad de formato monetario

/// Formato monetario único de la app (estilo europeo: 1.234,56 €).
enum Money {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()

    /// Devuelve "1.234,56" sin símbolo de moneda.
    static func amount(_ value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    /// Devuelve "€ 1.234,56", igual que en el prototipo.
    static func format(_ value: Double) -> String {
        "€ " + amount(value)
    }
}
