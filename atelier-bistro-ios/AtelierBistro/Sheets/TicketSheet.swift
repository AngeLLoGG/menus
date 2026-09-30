//
//  TicketSheet.swift
//  AtelierBistro
//
//  Seguimiento en vivo de la comanda: stepper de estado, ticket digital
//  con desglose de facturación, accesos de pago y simulador de avance.
//

import SwiftUI

struct TicketSheet: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        SheetContainer {
            VStack(spacing: 0) {
                header

                if let order = store.activeOrder {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            stepper(for: order)
                            printedTicket(for: order)
                            paymentActions
                            demoControls
                        }
                        .padding(20)
                    }
                }

                footer
            }
        }
    }

    // MARK: - Cabecera

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Seguimiento en Vivo")
                    .font(.atelierMono(10))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .foregroundStyle(Theme.textMuted)

                Text("Ticket #\(store.activeOrder?.id ?? "—")")
                    .font(.atelier(14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
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
            .accessibilityLabel("Cerrar ticket")
        }
        .padding(16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }

    // MARK: - Stepper de estado

    private func stepper(for order: KitchenOrder) -> some View {
        let steps = OrderStatus.allCases
        let currentIndex = steps.firstIndex(of: order.status) ?? 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Estado del Servicio")
                    .font(.atelierMono(11))
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.zinc400)

                Spacer()

                Text(order.status.customerLabel)
                    .font(.atelierMono(11, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.textPrimary)
            }

            HStack(spacing: 6) {
                ForEach(Array(steps.enumerated()), id: \.element) { index, _ in
                    Capsule()
                        .fill(index <= currentIndex ? Theme.ink : Theme.zinc200)
                        .frame(height: 6)
                }
            }

            HStack(spacing: 4) {
                ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                    Text(step.customerLabel)
                        .font(.atelierMono(9, weight: index <= currentIndex ? .semibold : .regular))
                        .foregroundStyle(index <= currentIndex ? Theme.textPrimary : Theme.zinc400)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Ticket digital

    private func printedTicket(for order: KitchenOrder) -> some View {
        let subtotal = order.effectiveSubtotal
        let baseSubtotal = subtotal / (1 + OrderTotals.taxRate)
        let tax = subtotal - baseSubtotal
        let tip = order.effectiveTip
        let grandTotal = subtotal + tip

        return VStack(alignment: .leading, spacing: 12) {
            ticketField(label: "Mesa", value: order.table, monospaced: true)

            ticketField(
                label: "Hora de envío",
                value: order.createdAt.formatted(date: .omitted, time: .shortened),
                monospaced: false
            )

            VStack(alignment: .leading, spacing: 10) {
                ForEach(order.items) { item in
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(item.quantity)x \(item.name)")
                            .font(.atelierMono(12, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)

                        if !item.options.isEmpty {
                            Text(item.options.map { "+ \($0)" }.joined(separator: " · "))
                                .font(.atelierMono(10))
                                .foregroundStyle(Theme.zinc500)
                                .padding(.leading, 8)
                        }

                        if !item.kitchenNote.isEmpty {
                            Text("Nota: \(item.kitchenNote)")
                                .font(.atelierMono(10))
                                .italic()
                                .foregroundStyle(Theme.zinc400)
                                .padding(.leading, 8)
                        }
                    }
                    .padding(.bottom, 8)
                    .overlay(alignment: .bottom) {
                        if item.id != order.items.last?.id {
                            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
                        }
                    }
                }
            }
            .padding(.top, 4)

            VStack(spacing: 4) {
                ticketRow(label: "Subtotal", value: Money.format(baseSubtotal))
                ticketRow(label: "IVA (10%)", value: Money.format(tax))
                ticketRow(label: "Propina voluntaria", value: Money.format(tip))
            }
            .padding(.top, 8)
            .overlay(alignment: .top) {
                Rectangle().fill(Theme.zinc200).frame(height: 1)
            }

            HStack {
                Text("Total Facturado")
                    .font(.atelierMono(14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Text(Money.format(grandTotal))
                    .font(.atelierMono(14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.top, 8)
            .overlay(alignment: .top) {
                Rectangle().fill(Theme.zinc300).frame(height: 1)
            }
        }
        .padding(16)
        .background(Theme.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.zinc200, lineWidth: 1)
        )
    }

    private func ticketField(label: String, value: String, monospaced: Bool) -> some View {
        HStack {
            Text(label)
                .font(.atelierMono(12))
                .foregroundStyle(Theme.zinc500)

            Spacer()

            Text(value)
                .font(monospaced ? .atelierMono(12, weight: .semibold) : .atelierMono(12))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.zinc200).frame(height: 1)
        }
    }

    private func ticketRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.atelierMono(11))
                .foregroundStyle(Theme.zinc600)
            Spacer()
            Text(value)
                .font(.atelierMono(11))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    // MARK: - Operaciones de pago

    private var paymentActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Operaciones de Pago")
                    .font(.atelier(12, weight: .medium))
                    .foregroundStyle(Theme.zinc800)

                Spacer()

                Text("Mesa Compartida")
                    .font(.atelierMono(10))
                    .foregroundStyle(Theme.zinc500)
            }

            HStack(spacing: 8) {
                Button {
                    store.openSplitBill(origin: .ticket)
                } label: {
                    CompactActionLabel(title: "Dividir Cuenta", systemName: "person.badge.plus")
                }
                .buttonStyle(.plain)

                Button {
                    store.openTipAdjustment()
                } label: {
                    CompactActionLabel(title: "Ajustar Propina", systemName: "clock")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Theme.zinc100)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.zinc200, lineWidth: 1)
        )
    }

    // MARK: - Simulador de avance (demo)

    private var demoControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Simular avance de comanda (Demo)")
                .font(.atelierMono(10))
                .textCase(.uppercase)
                .foregroundStyle(Theme.zinc500)

            HStack(spacing: 6) {
                Button {
                    store.advanceActiveOrderStatus()
                } label: {
                    Text("+ Siguiente Estado")
                        .font(.atelierMono(11))
                        .foregroundStyle(Theme.zinc800)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(Theme.zinc300, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    store.resetActiveOrderDemo()
                } label: {
                    Text("Reiniciar")
                        .font(.atelierMono(11))
                        .foregroundStyle(Theme.zinc500)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 7)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Theme.zinc100.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.zinc200, lineWidth: 1)
        )
    }

    // MARK: - Pie

    private var footer: some View {
        Button {
            store.dismissAllOverlays()
        } label: {
            Text("Volver a la carta")
                .font(.atelier(12, weight: .medium))
                .foregroundStyle(Theme.zinc600)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(Theme.surface)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }
}

// MARK: - Botón compacto de operación

struct CompactActionLabel: View {
    let title: String
    let systemName: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(.atelier(12, weight: .medium))
        }
        .foregroundStyle(Theme.zinc800)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(Theme.zinc300, lineWidth: 1)
        )
    }
}
