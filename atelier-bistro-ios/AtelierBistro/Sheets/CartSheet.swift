//
//  CartSheet.swift
//  AtelierBistro
//
//  Resumen de comanda: líneas del carrito, selector de propina
//  (porcentaje o importe libre), desglose económico y envío a cocina.
//

import SwiftUI

struct CartSheet: View {
    @EnvironmentObject private var store: AppStore
    @State private var customTipText: String = ""

    private let tipPercentages: [Double] = [0, 5, 10, 15]

    var body: some View {
        SheetContainer {
            VStack(spacing: 0) {
                header

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if store.isCartEmpty {
                                emptyState
                            } else {
                                cartLines
                                tipSection.id("tip-section")
                                splitPrompt
                            }
                        }
                        .padding(16)
                    }
                    .onChange(of: store.highlightTipSection) { shouldHighlight in
                        guard shouldHighlight else { return }
                        withAnimation {
                            proxy.scrollTo("tip-section", anchor: .center)
                        }
                        store.highlightTipSection = false
                    }
                }

                summary
            }
        }
    }

    // MARK: - Cabecera

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Text("Resumen de Comanda")
                    .font(.atelier(14, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)

                TagLabel(
                    text: "Mesa 04",
                    background: Theme.zinc100,
                    border: Theme.zinc200,
                    foreground: Theme.zinc600
                )
            }

            Spacer()

            Button {
                store.pop()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.zinc400)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cerrar resumen")
        }
        .padding(16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }

    // MARK: - Líneas del carrito

    private var cartLines: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(store.cart) { item in
                CartLineRow(item: item) {
                    store.removeCartItem(item.id)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bag")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Theme.zinc300)

            Text("El carrito está vacío.")
                .font(.atelierMono(12))
                .foregroundStyle(Theme.textMuted)

            Button {
                store.pop()
            } label: {
                Text("Explorar carta")
                    .font(.atelier(12))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Theme.zinc200, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Propina

    private var tipSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Propina de Servicio")
                    .font(.atelier(12, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Text(store.tipMode.displayLabel)
                    .font(.atelierMono(10))
                    .foregroundStyle(Theme.zinc500)
            }

            HStack(spacing: 6) {
                ForEach(tipPercentages, id: \.self) { percentage in
                    TipPercentageButton(
                        percentage: percentage,
                        isSelected: store.selectedTipPercentage == percentage
                    ) {
                        customTipText = ""
                        store.setTipOption(percentage)
                    }
                }
            }

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("S/")
                        .font(.atelierMono(11))
                        .foregroundStyle(Theme.zinc400)

                    TextField("Importe libre...", text: $customTipText)
                        .font(.atelierMono(12))
                        .keyboardType(.decimalPad)
                        .foregroundStyle(Theme.textPrimary)
                        .onChange(of: customTipText) { newValue in
                            applyCustomTip(newValue)
                        }
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 7)
                .background(Theme.canvas)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Theme.borderSand, lineWidth: 1)
                )

                Button {
                    customTipText = ""
                    store.clearTip()
                } label: {
                    Text("Limpiar")
                        .font(.atelierMono(11))
                        .foregroundStyle(Theme.zinc500)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(Theme.zinc200, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }

    /// Interpreta el importe libre escrito, aceptando coma o punto decimal.
    private func applyCustomTip(_ raw: String) {
        let normalized = raw.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else {
            store.clearTip()
            return
        }
        store.setCustomTip(value)
    }

    // MARK: - Acceso a dividir cuenta

    private var splitPrompt: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("¿Comparten esta cuenta?")
                    .font(.atelier(12, weight: .medium))
                    .foregroundStyle(Theme.zinc800)

                Text("Calcula partes iguales o pago por ítems.")
                    .font(.atelier(11))
                    .foregroundStyle(Theme.zinc500)
            }

            Spacer(minLength: 0)

            Button {
                store.openSplitBill(origin: .cart)
            } label: {
                Text("Dividir")
                    .font(.atelier(12, weight: .medium))
                    .foregroundStyle(Theme.zinc800)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Theme.zinc300, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Theme.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.zinc200, lineWidth: 1)
        )
    }

    // MARK: - Resumen económico y confirmación

    private var summary: some View {
        VStack(spacing: 12) {
            let totals = store.totals

            VStack(spacing: 4) {
                SummaryRow(label: "Subtotal", value: Money.format(totals.baseSubtotal))
                SummaryRow(label: "Impuestos (10% IVA incl.)", value: Money.format(totals.tax))
                SummaryRow(label: "Propina añadida", value: Money.format(totals.tipAmount))

                HStack {
                    Text("Total a Pagar")
                        .font(.atelier(14, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(Money.format(totals.grandTotal))
                        .font(.atelierMono(14, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(.top, 8)
                .overlay(alignment: .top) {
                    Rectangle().fill(Theme.zinc200).frame(height: 1)
                }
            }

            HStack(spacing: 8) {
                SecondaryActionButton(title: "Dividir Cuenta", systemImage: "person.badge.plus") {
                    store.openSplitBill(origin: .cart)
                }

                PrimaryActionButton(
                    title: "Pedir y Enviar",
                    systemImage: "chevron.right",
                    isEnabled: !store.isCartEmpty
                ) {
                    store.confirmOrder()
                }
            }
        }
        .padding(16)
        .background(Theme.canvas)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.zinc200).frame(height: 1)
        }
    }
}

// MARK: - Fila de línea del carrito

struct CartLineRow: View {
    let item: CartItem
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(item.quantity)x \(item.name)")
                        .font(.atelier(12, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Text(Money.format(item.lineTotal))
                        .font(.atelierMono(11))
                        .foregroundStyle(Theme.zinc500)
                }

                Spacer(minLength: 8)

                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.zinc400)
                        .padding(4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Eliminar ítem")
            }

            if !item.modifiers.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(item.modifiers.enumerated()), id: \.offset) { _, modifier in
                        Text("+ \(modifier)")
                            .font(.atelierMono(10))
                            .foregroundStyle(Theme.zinc500)
                    }
                }
                .padding(.leading, 9)
                .overlay(alignment: .leading) {
                    Rectangle().fill(Theme.zinc200).frame(width: 2)
                }
            }

            if !item.note.isEmpty {
                Text("Nota: \"\(item.note)\"")
                    .font(.atelierMono(10))
                    .foregroundStyle(Theme.zinc500)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.zinc100)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Theme.zinc200, lineWidth: 1)
                    )
            }
        }
        .padding(.bottom, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }
}

// MARK: - Botón de porcentaje de propina

struct TipPercentageButton: View {
    let percentage: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(Int(percentage))%")
                .font(.atelierMono(12, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : Theme.zinc700)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(isSelected ? Theme.ink : Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(isSelected ? Theme.ink : Theme.zinc200, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fila de resumen

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.atelier(12))
                .foregroundStyle(Theme.zinc500)
            Spacer()
            Text(value)
                .font(.atelierMono(12))
                .foregroundStyle(Theme.zinc800)
        }
    }
}
