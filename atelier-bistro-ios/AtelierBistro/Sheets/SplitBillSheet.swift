//
//  SplitBillSheet.swift
//  AtelierBistro
//
//  División de cuenta con dos modos: partes iguales entre comensales
//  o pago por ítems de consumo, con propina proporcional y barra de
//  progreso de cobro de la mesa.
//

import SwiftUI

struct SplitBillSheet: View {
    @EnvironmentObject private var store: AppStore

    private let guestPresets = [2, 3, 4, 5]

    var body: some View {
        SheetContainer {
            VStack(spacing: 0) {
                header
                modeSelector

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if store.splitMode == .equal {
                            equalModeContent
                        } else {
                            itemsModeContent
                        }
                    }
                    .padding(16)
                }

                footer
            }
        }
    }

    // MARK: - Cabecera

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Servicio en Mesa 04")
                    .font(.atelierMono(10))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .foregroundStyle(Theme.textMuted)

                Text("Dividir Cuenta")
                    .font(.atelier(14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            Spacer()

            Button {
                store.closeSplitBill()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.zinc400)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cerrar división de cuenta")
        }
        .padding(16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.borderSandLight).frame(height: 1)
        }
    }

    // MARK: - Selector de modo

    private var modeSelector: some View {
        HStack(spacing: 2) {
            ForEach(SplitMode.allCases, id: \.self) { mode in
                let isActive = store.splitMode == mode

                Button {
                    store.switchSplitMode(mode)
                } label: {
                    Text(mode.label)
                        .font(.atelier(12, weight: isActive ? .medium : .regular))
                        .foregroundStyle(isActive ? Theme.textPrimary : Theme.zinc600)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(isActive ? Theme.surface : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .shadow(color: isActive ? .black.opacity(0.06) : .clear, radius: 2, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(Theme.zinc200.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.canvas)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.zinc200).frame(height: 1)
        }
    }

    // MARK: - Modo A: partes iguales

    private var equalModeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            guestStepper
            perPersonCard
            sharesList
        }
    }

    private var guestStepper: some View {
        VStack(spacing: 12) {
            Text("¿Entre cuántos comensales dividen?")
                .font(.atelier(12, weight: .medium))
                .foregroundStyle(Theme.zinc500)

            HStack(spacing: 14) {
                SplitStepperButton(systemName: "minus") {
                    store.changeSplitGuests(by: -1)
                }

                Text("\(store.splitGuests)")
                    .font(.atelierMono(20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 44)

                SplitStepperButton(systemName: "plus") {
                    store.changeSplitGuests(by: 1)
                }
            }

            HStack(spacing: 6) {
                ForEach(guestPresets, id: \.self) { preset in
                    Button {
                        store.setSplitGuests(preset)
                    } label: {
                        Text("\(preset) pers.")
                            .font(.atelierMono(11))
                            .foregroundStyle(Theme.zinc700)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(Theme.zinc200, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Theme.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.zinc200, lineWidth: 1)
        )
    }

    private var perPersonCard: some View {
        VStack(spacing: 10) {
            SummaryRow(
                label: "Total general (con propina):",
                value: Money.format(store.splitDataset.grandTotal)
            )
            SummaryRow(
                label: "Comensales:",
                value: "\(store.splitGuests) personas"
            )

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cuota por comensal")
                        .font(.atelier(12, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Importe exacto redondeado")
                        .font(.atelier(10))
                        .foregroundStyle(Theme.zinc400)
                }

                Spacer()

                Text(Money.format(store.splitPerPerson))
                    .font(.atelierMono(20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.top, 8)
            .overlay(alignment: .top) {
                Rectangle().fill(Theme.borderSandLight).frame(height: 1)
            }
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.zinc200, lineWidth: 1)
        )
    }

    private var sharesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Registro de pagos de la mesa")
                .font(.atelierMono(11))
                .textCase(.uppercase)
                .foregroundStyle(Theme.textMuted)

            ForEach(Array(0..<store.splitGuests), id: \.self) { index in
                let isMe = index == 0
                let isPaid = store.isGuestPaid(index)

                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(isPaid ? Theme.success : Theme.zinc200)
                            .frame(width: 20, height: 20)

                        if isPaid {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.atelierMono(10, weight: .semibold))
                                .foregroundStyle(Theme.zinc700)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(isMe ? "Tú (Este dispositivo)" : "Comensal \(index + 1)")
                            .font(.atelier(12, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)

                        Text(isPaid ? "Abonado" : "Pendiente de pago")
                            .font(.atelierMono(10))
                            .foregroundStyle(Theme.zinc400)
                    }

                    Spacer(minLength: 6)

                    Text(Money.format(store.splitPerPerson))
                        .font(.atelierMono(12, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(10)
                .background(isMe ? Theme.canvas : Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isMe ? Theme.ink : Theme.zinc200, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Modo B: por ítems

    private var itemsModeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Selecciona los platos que vas a pagar tú:")
                    .font(.atelier(12, weight: .medium))
                    .foregroundStyle(Theme.zinc800)

                Text("La propina proporcional se sumará a tus ítems.")
                    .font(.atelier(11))
                    .foregroundStyle(Theme.zinc400)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Theme.zinc200, lineWidth: 1)
            )

            VStack(spacing: 8) {
                ForEach(store.splitDataset.items) { item in
                    SplitItemRow(
                        item: item,
                        isSelected: store.isSplitItemSelected(item.id)
                    ) {
                        store.toggleSplitItem(item.id)
                    }
                }
            }

            VStack(spacing: 5) {
                SummaryRow(
                    label: "Tus platos seleccionados:",
                    value: Money.format(store.splitSelectedSubtotal)
                )
                SummaryRow(
                    label: "Propina proporcional:",
                    value: Money.format(store.splitSelectedTip)
                )

                HStack {
                    Text("Mi Total a Abonar:")
                        .font(.atelier(13, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(Money.format(store.splitSelectedSubtotal + store.splitSelectedTip))
                        .font(.atelierMono(13, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(.top, 6)
                .overlay(alignment: .top) {
                    Rectangle().fill(Theme.zinc200).frame(height: 1)
                }
            }
            .font(.atelierMono(12))
            .padding(12)
            .background(Theme.canvas.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Theme.zinc200, lineWidth: 1)
            )
        }
    }

    // MARK: - Pie con progreso y acciones de pago

    private var footer: some View {
        VStack(spacing: 10) {
            VStack(spacing: 5) {
                HStack {
                    Text("Mesa 04 abonado:")
                        .font(.atelierMono(11))
                        .foregroundStyle(Theme.zinc500)

                    Spacer()

                    Text("\(Money.format(store.splitTablePaidTotal)) / \(Money.format(store.splitDataset.grandTotal)) (\(Int((store.splitProgress * 100).rounded()))%)")
                        .font(.atelierMono(11, weight: .semibold))
                        .foregroundStyle(Theme.zinc800)
                }

                ProgressRail(progress: store.splitProgress)
            }

            HStack(spacing: 8) {
                PrimaryActionButton(
                    title: "Pagar mi parte (\(Money.format(store.splitMyShare)))",
                    systemImage: "creditcard",
                    isEnabled: store.splitMyShare > 0
                ) {
                    store.executeSharePayment()
                }

                SecondaryActionButton(title: "Pagar Cuenta Total") {
                    store.executeFullPayment()
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

// MARK: - Componentes auxiliares

struct SplitStepperButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.zinc700)
                .frame(width: 36, height: 36)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Theme.zinc300, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SplitItemRow: View {
    let item: SplitLine
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
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

                Text("\(item.quantity)x \(item.name)")
                    .font(.atelier(12, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Text(Money.format(item.totalPrice))
                    .font(.atelierMono(12))
                    .foregroundStyle(Theme.zinc800)
            }
            .padding(10)
            .background(isSelected ? Theme.canvas : Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? Theme.ink : Theme.zinc200, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
