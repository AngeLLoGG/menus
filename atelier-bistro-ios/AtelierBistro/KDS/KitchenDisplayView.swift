//
//  KitchenDisplayView.swift
//  AtelierBistro
//
//  KDS de cocina: barra de control con filtros por estado, tablero de
//  comandas en rejilla adaptativa y pie con métricas de servicio.
//

import SwiftUI

struct KitchenDisplayView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 0) {
            controlBar
            board
            statusFooter
        }
        .background(Theme.canvas)
    }

    // MARK: - Barra de control

    private var controlBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Theme.terracotta)
                    .frame(width: 10, height: 10)

                Text("KDS Cocina Central")
                    .font(.atelier(14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Rectangle()
                    .fill(Theme.zinc300)
                    .frame(width: 1, height: 14)

                HStack(spacing: 4) {
                    Text("\(store.activeKitchenCount)")
                        .font(.atelierMono(12, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("comandas activas")
                        .font(.atelierMono(12))
                        .foregroundStyle(Theme.zinc500)
                }

                Spacer(minLength: 8)

                Button {
                    store.generateRandomKitchenOrder()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text("Nueva Comanda")
                            .font(.atelierMono(11))
                    }
                    .foregroundStyle(Theme.zinc700)
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
                .accessibilityLabel("Inyectar comanda de prueba")
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    KdsFilterPill(
                        title: "Todas",
                        count: nil,
                        isActive: store.kdsFilter == nil
                    ) {
                        store.setKdsFilter(nil)
                    }

                    // El prototipo ofrece «Todas» más los tres estados operativos.
                    // Las comandas entregadas permanecen en «Todas» hasta archivarse.
                    ForEach(OrderStatus.allCases.filter { $0 != .delivered }, id: \.self) { status in
                        KdsFilterPill(
                            title: status.filterLabel,
                            count: store.count(for: status),
                            isActive: store.kdsFilter == status
                        ) {
                            store.setKdsFilter(status)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Theme.surface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSand).frame(height: 1)
        }
    }

    // MARK: - Tablero

    private var board: some View {
        ScrollView {
            if store.filteredKitchenOrders.isEmpty {
                Text("No hay comandas en este estado.")
                    .font(.atelierMono(12))
                    .foregroundStyle(Theme.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else {
                // Se refresca cada 15 s para actualizar los cronómetros de cocina.
                TimelineView(.periodic(from: .now, by: 15)) { context in
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 290), spacing: 14)],
                        alignment: .leading,
                        spacing: 14
                    ) {
                        ForEach(store.filteredKitchenOrders) { order in
                            KdsOrderCard(order: order, now: context.date)
                        }
                    }
                    .padding(18)
                }
            }
        }
    }

    // MARK: - Pie de métricas

    private var statusFooter: some View {
        HStack(spacing: 8) {
            Text("Tiempo prom. cocina: \(averageKitchenTime)")
                .font(.atelierMono(11))
                .foregroundStyle(Theme.textSecondary)

            Text("·")
                .foregroundStyle(Theme.zinc300)

            Text("Alertas de demora > 15m")
                .font(.atelierMono(11))
                .foregroundStyle(Theme.textSecondary)

            Spacer(minLength: 8)

            Circle()
                .fill(Theme.success)
                .frame(width: 8, height: 8)

            Text("Impresora de tickets: Online")
                .font(.atelierMono(11))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Theme.surface)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.borderSand).frame(height: 1)
        }
    }

    /// Media de tiempo de las comandas aún no entregadas.
    private var averageKitchenTime: String {
        let active = store.kitchenOrders.filter { $0.status != .delivered }
        guard !active.isEmpty else { return "—" }

        let totalSeconds = active.reduce(0) { $0 + Int(Date().timeIntervalSince($1.createdAt)) }
        let average = max(0, totalSeconds / active.count)

        return "\(average / 60)m \(average % 60)s"
    }
}

// MARK: - Píldora de filtro

struct KdsFilterPill: View {
    let title: String
    let count: Int?
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.atelier(12, weight: isActive ? .medium : .regular))

                if let count {
                    Text("(\(count))")
                        .font(.atelier(12))
                }
            }
            .foregroundStyle(isActive ? Theme.textPrimary : Theme.zinc600)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? Theme.surface : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(isActive ? Theme.zinc200 : Color.clear, lineWidth: 1)
            )
            .shadow(color: isActive ? .black.opacity(0.06) : .clear, radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tarjeta de comanda

struct KdsOrderCard: View {
    @EnvironmentObject private var store: AppStore

    let order: KitchenOrder
    let now: Date

    private var elapsedMinutes: Int { order.elapsedMinutes(from: now) }
    private var isDelayed: Bool { order.status != .delivered && order.isDelayed(from: now) }

    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            itemsBody
            cardFooter
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.kdsBorder(for: order), lineWidth: isDelayed ? 1.5 : 1)
        )
        .overlay(alignment: .top) {
            // Franja superior de color según el estado de preparación.
            Rectangle()
                .fill(Theme.kdsAccent(for: order.status))
                .frame(height: 3)
        }
        // Recorta también la franja superior para respetar las esquinas redondeadas.
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        .opacity(order.status == .delivered ? 0.6 : 1)
    }

    // MARK: Cabecera

    private var cardHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("MESA \(order.table)")
                    .font(.atelierMono(11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                Text("#\(order.id)")
                    .font(.atelierMono(11, weight: .medium))
                    .foregroundStyle(Theme.zinc500)

                Spacer(minLength: 6)

                if isDelayed {
                    TagLabel(
                        text: "Demora \(elapsedMinutes)m",
                        background: Theme.amberTagBg,
                        border: Theme.amberTagBorder,
                        foreground: Theme.amberTagText
                    )
                } else {
                    Text("\(elapsedMinutes)m")
                        .font(.atelierMono(12))
                        .foregroundStyle(Theme.zinc500)
                }
            }

            if !order.notes.isEmpty {
                Text(order.notes)
                    .font(.atelierMono(11))
                    .foregroundStyle(Theme.alertPeachText)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Theme.alertPeachBg)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Theme.alertPeachBorder, lineWidth: 1)
                    )
            }
        }
        .padding(14)
        .background(Theme.canvas.opacity(0.55))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }

    // MARK: Líneas de cocina

    private var itemsBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(order.items) { item in
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(item.quantity)x \(item.name)")
                        .font(.atelierMono(12, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if !item.options.isEmpty {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(Array(item.options.enumerated()), id: \.offset) { _, option in
                                Text("• \(option)")
                                    .font(.atelierMono(11))
                                    .foregroundStyle(Theme.zinc600)
                            }
                        }
                        .padding(.leading, 10)
                    }

                    if !item.kitchenNote.isEmpty {
                        Text("Nota: \(item.kitchenNote)")
                            .font(.atelier(11, weight: .medium))
                            .foregroundStyle(Theme.zinc800)
                            .padding(.horizontal, 8)
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
                .padding(.bottom, 8)
                .overlay(alignment: .bottom) {
                    if item.id != order.items.last?.id {
                        Rectangle().fill(Theme.borderSandLight).frame(height: 1)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Pie con acción de avance

    private var cardFooter: some View {
        HStack(spacing: 8) {
            Text(order.status.shortLabel)
                .font(.atelierMono(10))
                .tracking(0.5)
                .foregroundStyle(Theme.textMuted)

            Spacer(minLength: 6)

            if let nextLabel = order.status.advanceLabel {
                Button {
                    store.advanceKitchenOrder(order.id)
                } label: {
                    HStack(spacing: 5) {
                        Text(nextLabel)
                            .font(.atelier(12, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Theme.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    store.archiveKitchenOrder(order.id)
                } label: {
                    Text("Archivar")
                        .font(.atelierMono(12))
                        .foregroundStyle(Theme.zinc500)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Theme.canvas)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }
}
