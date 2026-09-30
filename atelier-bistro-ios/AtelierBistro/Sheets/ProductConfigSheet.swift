//
//  ProductConfigSheet.swift
//  AtelierBistro
//
//  Modal de personalización de plato: grupos obligatorios y opcionales,
//  nota para cocina, selector de cantidad y total en tiempo real.
//

import SwiftUI

struct ProductConfigSheet: View {
    @EnvironmentObject private var store: AppStore
    let product: Product

    var body: some View {
        SheetContainer {
            VStack(spacing: 0) {
                header
                options
                footer
            }
        }
    }

    // MARK: - Cabecera

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(store.categoryName(for: product.categoryId))
                    .font(.atelierMono(10, weight: .medium))
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(Theme.textMuted)

                Text(product.name)
                    .font(.atelier(16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text(product.description)
                    .font(.atelier(12))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text(Money.format(product.price))
                    .font(.atelierMono(14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Button {
                store.closeProductConfig()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.zinc400)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cerrar modal")
        }
        .padding(16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }

    // MARK: - Opciones

    private var options: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(product.modifiers) { group in
                    modifierGroup(group)
                }

                kitchenNoteField
            }
            .padding(16)
        }
    }

    private func modifierGroup(_ group: ModifierGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(group.name)
                    .font(.atelier(12, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                if group.isRequired {
                    TagLabel(
                        text: "Obligatorio",
                        background: Theme.zinc200,
                        border: Theme.zinc200,
                        foreground: Theme.zinc700,
                        uppercase: true
                    )
                } else {
                    Text("Opcional")
                        .font(.atelierMono(9))
                        .foregroundStyle(Theme.zinc400)
                }
            }

            VStack(spacing: 6) {
                ForEach(group.options) { option in
                    ModifierOptionRow(
                        option: option,
                        kind: group.kind,
                        isSelected: isSelected(group: group, option: option)
                    ) {
                        store.toggleModifier(
                            groupID: group.id,
                            optionID: option.id,
                            kind: group.kind,
                            isSelected: !isSelected(group: group, option: option)
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.canvas.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.borderSand, lineWidth: 1)
        )
    }

    private func isSelected(group: ModifierGroup, option: ModifierOption) -> Bool {
        switch group.kind {
        case .single:
            return store.configState.singleSelections[group.id] == option.id
        case .multiple:
            return store.configState.multiSelections.contains(option.id)
        }
    }

    private var kitchenNoteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Instrucciones o alergias para la cocina")
                .font(.atelier(11, weight: .medium))
                .foregroundStyle(Theme.zinc700)

            TextField(
                "Ej. Sin cebolla, salsa aparte, alérgico a...",
                text: Binding(
                    get: { store.configState.kitchenNote },
                    set: { store.setConfigNote($0) }
                ),
                axis: .vertical
            )
            .font(.atelier(12))
            .lineLimit(3...5)
            .padding(10)
            .background(Theme.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Theme.borderSand, lineWidth: 1)
            )
        }
    }

    // MARK: - Pie con cantidad y total

    private var footer: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Cantidad")
                    .font(.atelier(12, weight: .medium))
                    .foregroundStyle(Theme.zinc600)

                Spacer()

                HStack(spacing: 0) {
                    QuantityButton(systemName: "minus") {
                        store.changeConfigQuantity(by: -1)
                    }

                    Text("\(store.configState.quantity)")
                        .font(.atelierMono(13, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 34, height: 32)

                    QuantityButton(systemName: "plus") {
                        store.changeConfigQuantity(by: 1)
                    }
                }
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Theme.zinc200, lineWidth: 1)
                )
            }

            PrimaryActionButton(
                title: "Añadir a la orden",
                trailingText: Money.format(store.configRunningTotal)
            ) {
                store.submitProductToCart()
            }
        }
        .padding(16)
        .background(Theme.canvas.opacity(0.5))
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }
}

// MARK: - Componentes auxiliares

/// Fila de opción con radio (selección única) o checkbox (múltiple).
struct ModifierOptionRow: View {
    let option: ModifierOption
    let kind: ModifierGroup.Kind
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                indicator

                Text(option.name)
                    .font(.atelier(12, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Text(option.price > 0 ? "+\(Money.format(option.price))" : "Incluido")
                    .font(.atelierMono(11))
                    .foregroundStyle(option.price > 0 ? Theme.textSecondary : Theme.textMuted)
            }
            .padding(9)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(isSelected ? Theme.ink : Theme.zinc200, lineWidth: isSelected ? 1.4 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    @ViewBuilder
    private var indicator: some View {
        switch kind {
        case .single:
            ZStack {
                Circle()
                    .stroke(isSelected ? Theme.ink : Theme.zinc300, lineWidth: 1.4)
                    .frame(width: 16, height: 16)
                if isSelected {
                    Circle()
                        .fill(Theme.ink)
                        .frame(width: 8, height: 8)
                }
            }
        case .multiple:
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(isSelected ? Theme.ink : Color.clear)
                    .frame(width: 16, height: 16)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(isSelected ? Theme.ink : Theme.zinc300, lineWidth: 1.4)
                    .frame(width: 16, height: 16)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

/// Botón cuadrado de cantidad (+ / −).
struct QuantityButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.zinc600)
                .frame(width: 34, height: 32)
        }
        .buttonStyle(.plain)
    }
}
