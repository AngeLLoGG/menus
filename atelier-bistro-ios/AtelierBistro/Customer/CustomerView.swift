//
//  CustomerView.swift
//  AtelierBistro
//
//  Vista del comensal (mobile-first). Equivale al bloque #customer-viewport
//  del prototipo: cabecera, buscador, categorías, catálogo y pie informativo.
//

import SwiftUI

struct CustomerView: View {
    @EnvironmentObject private var store: AppStore
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            searchBar
            categoryBar
            if store.hasActiveOrder {
                activeOrderBanner
            }
            catalog
            footer
        }
        .background(Theme.surface)
    }

    // MARK: - Cabecera

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Atelier Bistro")
                        .font(.atelier(11, weight: .semibold))
                        .textCase(.uppercase)
                        .tracking(0.6)
                        .foregroundStyle(Theme.textMuted)

                    TagLabel(
                        text: "Mesa 04",
                        background: Theme.tableTagBg,
                        border: Theme.tableTagBorder,
                        foreground: Theme.tableTagText
                    )
                }

                Text("Carta Digital")
                    .font(.atelier(16, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
            }

            Spacer(minLength: 8)

            HStack(spacing: 2) {
                // Acción directa: dividir cuenta
                IconButton(systemName: "person.badge.plus", accessibility: "Dividir cuenta") {
                    store.openSplitBill(origin: .direct)
                }

                // Seguimiento de la comanda en curso
                if store.hasActiveOrder {
                    IconButton(
                        systemName: "doc.text",
                        accessibility: "Ver estado del pedido",
                        showsDot: true
                    ) {
                        store.openTicket()
                    }
                }

                // Carrito con contador
                Button {
                    store.openCart()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bag")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Theme.textPrimary)

                        Text("\(store.cartBadgeCount)")
                            .font(.atelierMono(11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .frame(minWidth: 18)
                            .background(Theme.ink)
                            .clipShape(Capsule())
                    }
                    .padding(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Abrir carrito")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Theme.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.borderSandLight)
                .frame(height: 1)
        }
    }

    // MARK: - Buscador

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.zinc400)

            TextField("Buscar por plato, ingrediente...", text: $searchText)
                .font(.atelier(12))
                .foregroundStyle(Theme.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: searchText) { newValue in
                    store.searchQuery = newValue
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    store.clearSearch()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.zinc400)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Limpiar búsqueda")
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(Theme.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.borderSand, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Theme.surface)
    }

    // MARK: - Categorías

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.availableCategories) { category in
                    let isActive = store.currentCategory == category.id

                    Button {
                        store.setCategory(category.id)
                    } label: {
                        Text(category.name)
                            .font(.atelier(12, weight: isActive ? .medium : .regular))
                            .foregroundStyle(isActive ? .white : Theme.zinc600)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isActive ? Theme.ink : Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(isActive ? Theme.ink : Theme.zinc200, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(Theme.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.borderSandLight)
                .frame(height: 1)
        }
    }

    // MARK: - Banner de comanda activa

    private var activeOrderBanner: some View {
        Button {
            store.openTicket()
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(Theme.successLight)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Comanda #\(store.activeOrder?.id ?? "") en proceso")
                        .font(.atelier(12, weight: .medium))
                        .foregroundStyle(.white)

                    Text("Estado: \(store.activeOrder?.status.customerLabel ?? "")")
                        .font(.atelier(11))
                        .foregroundStyle(Theme.zinc400)
                }

                Spacer(minLength: 6)

                HStack(spacing: 3) {
                    Text("Ver ticket")
                        .font(.atelierMono(11))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Theme.zinc400)
            }
            .padding(12)
            .background(Theme.ink)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Catálogo

    private var catalog: some View {
        ScrollView {
            if store.filteredProducts.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(store.groupedCatalog) { section in
                        // Encabezado de sección solo cuando se agrupa por categorías
                        if section.isGrouped {
                            sectionHeader(section.category, count: section.products.count)
                        }

                        VStack(spacing: 10) {
                            ForEach(section.products) { product in
                                ProductCard(product: product) {
                                    store.openProductConfig(product.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Theme.surface)
    }

    private func sectionHeader(_ category: MenuCategory, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(category.name)
                .font(.atelierMono(11, weight: .semibold))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundStyle(Theme.textMuted)

            Text("(\(count))")
                .font(.atelierMono(10))
                .foregroundStyle(Theme.zinc300)
        }
        .padding(.bottom, 6)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.borderSandLight)
                .frame(height: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Theme.zinc300)

            Text("No se encontraron platos que coincidan.")
                .font(.atelierMono(12))
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Pie informativo

    private var footer: some View {
        HStack(spacing: 6) {
            Text("IVA incluido · Servicio directo a mesa")
                .font(.atelier(11))
                .foregroundStyle(Theme.textMuted)

            Text("·")
                .foregroundStyle(Theme.zinc300)

            Button {
                store.openSplitBill(origin: .direct)
            } label: {
                Text("Dividir cuenta")
                    .font(.atelier(11, weight: .medium))
                    .foregroundStyle(Theme.zinc700)
                    .underline()
            }
            .buttonStyle(.plain)

            Spacer(minLength: 6)

            Text("Mesa 04")
                .font(.atelierMono(11))
                .foregroundStyle(Theme.zinc500)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Theme.canvas)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.borderSand)
                .frame(height: 1)
        }
    }
}

// MARK: - Botón de icono reutilizable

struct IconButton: View {
    let systemName: String
    let accessibility: String
    var showsDot: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Theme.zinc700)
                .padding(7)
                .overlay(alignment: .topTrailing) {
                    if showsDot {
                        Circle()
                            .fill(Theme.success)
                            .frame(width: 7, height: 7)
                            .offset(x: -3, y: 3)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibility)
    }
}

// MARK: - Tarjeta de plato

struct ProductCard: View {
    let product: Product
    let onCustomize: () -> Void

    private var hasModifiers: Bool { !product.modifiers.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                Text(product.name)
                    .font(.atelier(13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                if !product.isAvailable {
                    TagLabel(
                        text: "Agotado",
                        background: Theme.zinc200,
                        border: Theme.zinc200,
                        foreground: Theme.zinc600,
                        uppercase: true
                    )
                }
            }

            Text(product.description)
                .font(.atelier(11))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(Money.format(product.price))
                    .font(.atelierMono(13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Spacer(minLength: 8)

                if product.isAvailable {
                    Button(action: onCustomize) {
                        HStack(spacing: 5) {
                            Text(hasModifiers ? "Personalizar" : "Añadir")
                                .font(.atelier(12, weight: .medium))
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(Theme.zinc200, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("No disponible hoy")
                        .font(.atelierMono(10))
                        .foregroundStyle(Theme.zinc400)
                }
            }
            .padding(.top, 2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(product.isAvailable ? Theme.surface : Theme.canvas.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(product.isAvailable ? Theme.zinc200 : Theme.borderSand, lineWidth: 1)
        )
        .opacity(product.isAvailable ? 1 : 0.6)
    }
}
