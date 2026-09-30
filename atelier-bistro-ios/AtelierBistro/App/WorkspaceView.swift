//
//  WorkspaceView.swift
//  AtelierBistro
//
//  Área de trabajo adaptativa del prototipo: barra superior con selector
//  de vistas (dual / comensal / cocina), marco de smartphone para la
//  vista del comensal y host de capas modales apiladas.
//

import SwiftUI

// MARK: - Modos de workspace

enum WorkspaceMode: String, CaseIterable, Identifiable {
    case dual
    case customer
    case kds

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dual: return "Vista Dual (Comensal + Cocina)"
        case .customer: return "Comensal (Móvil)"
        case .kds: return "KDS Cocina (Pantalla Completa)"
        }
    }

    var shortLabel: String {
        switch self {
        case .dual: return "Dual"
        case .customer: return "Comensal"
        case .kds: return "Cocina"
        }
    }
}

// MARK: - Workspace

struct WorkspaceView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var mode: WorkspaceMode = .dual

    /// En iPhone no cabe la vista dual, así que se degrada a comensal.
    private var effectiveMode: WorkspaceMode {
        if sizeClass != .regular && mode == .dual { return .customer }
        return mode
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                AppHeader(mode: $mode, showsModePicker: sizeClass == .regular)
                workspace
            }

            OverlayHost()
        }
        .background(Theme.canvas)
        .alert(
            store.feedback?.title ?? "",
            isPresented: Binding(
                get: { store.feedback != nil },
                set: { if !$0 { store.feedback = nil } }
            ),
            presenting: store.feedback
        ) { _ in
            Button("Entendido") { store.feedback = nil }
        } message: { feedback in
            Text(feedback.message)
        }
    }

    @ViewBuilder
    private var workspace: some View {
        switch effectiveMode {
        case .dual:
            HStack(spacing: 0) {
                CustomerCanvas {
                    CustomerView()
                }
                .frame(width: 460)

                Rectangle()
                    .fill(Theme.borderSand)
                    .frame(width: 1)

                KitchenDisplayView()
            }

        case .customer:
            CustomerCanvas(isCompact: sizeClass != .regular) {
                CustomerView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .kds:
            KitchenDisplayView()
        }
    }
}

// MARK: - Barra superior global

struct AppHeader: View {
    @Binding var mode: WorkspaceMode
    let showsModePicker: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Identidad de marca
            HStack(spacing: 10) {
                Text("S")
                    .font(.atelierMono(11, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Theme.terracotta)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                HStack(spacing: 6) {
                    Text("ATELIER")
                        .font(.atelier(13, weight: .semibold))
                        .tracking(0.3)
                        .foregroundStyle(Theme.textPrimary)

                    Text("v2.5 / Smart Order & Pay")
                        .font(.atelierMono(10))
                        .foregroundStyle(Theme.zinc400)
                }
            }

            Spacer(minLength: 8)

            if showsModePicker {
                modePicker
            } else {
                compactModePicker
            }

            Spacer(minLength: 8)

            // Estado de sincronización y reloj
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Theme.success)
                        .frame(width: 6, height: 6)
                    Text("Sincronización Activa")
                        .font(.atelierMono(10))
                        .foregroundStyle(Theme.zinc500)
                }

                Text("|")
                    .font(.atelierMono(10))
                    .foregroundStyle(Theme.zinc300)

                TimelineView(.periodic(from: .now, by: 10)) { context in
                    Text(context.date.formatted(date: .omitted, time: .shortened))
                        .font(.atelierMono(11))
                        .foregroundStyle(Theme.zinc500)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Theme.surface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSand).frame(height: 1)
        }
    }

    private var modePicker: some View {
        HStack(spacing: 2) {
            ForEach(WorkspaceMode.allCases) { option in
                let isActive = mode == option

                Button {
                    mode = option
                } label: {
                    Text(option.label)
                        .font(.atelier(11, weight: isActive ? .medium : .regular))
                        .foregroundStyle(isActive ? Theme.textPrimary : Theme.zinc600)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(isActive ? Theme.surface : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(isActive ? Theme.zinc200 : Color.clear, lineWidth: 1)
                        )
                        .shadow(color: isActive ? .black.opacity(0.06) : .clear, radius: 2, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(Theme.zinc100)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.zinc200, lineWidth: 1)
        )
    }

    private var compactModePicker: some View {
        Picker("Vista", selection: $mode) {
            ForEach(WorkspaceMode.allCases) { option in
                Text(option.shortLabel).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 240)
    }
}

// MARK: - Lienzo del comensal

/// Contiene la vista del comensal. En iPad se dibuja dentro de un marco
/// de smartphone con proporciones reales, como en el prototipo.
struct CustomerCanvas<Content: View>: View {
    var isCompact: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        Group {
            if isCompact {
                content()
            } else {
                PhoneFrame {
                    content()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.canvas)
    }
}

/// Marco estilizado de smartphone con barra de estado sutil.
struct PhoneFrame<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            statusBar

            content()
        }
        .frame(maxWidth: 420, maxHeight: 820)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.zinc300, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 16, y: 6)
    }

    private var statusBar: some View {
        HStack {
            TimelineView(.periodic(from: .now, by: 10)) { context in
                Text(context.date.formatted(date: .omitted, time: .shortened))
                    .font(.atelierMono(11))
                    .foregroundStyle(Theme.zinc400)
            }

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: "wifi")
                    .font(.system(size: 13, weight: .medium))

                Image(systemName: "battery.100")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(Theme.zinc600)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(Theme.surface)
    }
}

// MARK: - Host de capas modales

/// Presenta la pila de hojas apiladas (carrito, dividir cuenta, ticket…)
/// respetando el z-index del prototipo.
struct OverlayHost: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ForEach(Array(store.overlays.enumerated()), id: \.offset) { index, route in
                    let isTop = index == store.overlays.count - 1

                    ZStack(alignment: .bottom) {
                        Color.black.opacity(isTop ? 0.42 : 0.55)
                            .ignoresSafeArea()
                            .onTapGesture {
                                if isTop { dismiss(route) }
                            }

                        sheet(for: route)
                            .frame(height: geometry.size.height * heightFraction(for: route))
                            .frame(maxWidth: 560)
                            .frame(maxWidth: .infinity)
                    }
                    .allowsHitTesting(isTop)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(Double(index))
                }
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.9), value: store.overlays.count)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func sheet(for route: AppRoute) -> some View {
        switch route {
        case .productConfig(let productID):
            if let product = store.product(for: productID) {
                ProductConfigSheet(product: product)
            }
        case .cart:
            CartSheet()
        case .splitBill:
            SplitBillSheet()
        case .ticket:
            TicketSheet()
        }
    }

    private func heightFraction(for route: AppRoute) -> Double {
        switch route {
        case .productConfig: return 0.88
        case .cart, .splitBill, .ticket: return 0.92
        }
    }

    private func dismiss(_ route: AppRoute) {
        switch route {
        case .productConfig:
            store.closeProductConfig()
        case .cart, .ticket:
            store.pop()
        case .splitBill:
            store.closeSplitBill()
        }
    }
}
