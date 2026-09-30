//
//  Theme.swift
//  AtelierBistro
//
//  Paleta y tipografía del prototipo «gastronomic-theme».
//  Los colores se declaran de forma compatible con iOS 16+:
//  `Theme` expone los valores y `Color(hex:)` los materializa.
//

import SwiftUI

// MARK: - Paleta

/// Tokens de color del sistema de diseño.
enum Theme {

    // Lienzo y superficies
    static let canvas = Color(hex: 0xFAF8F5)          // --bg-warm-canvas
    static let surface = Color(hex: 0xFFFFFF)         // --surface-clean
    static let surfaceSubtle = Color(hex: 0xF6F3EE)   // .bg-sand-subtle

    // Bordes
    static let borderSand = Color(hex: 0xE7E2DA)      // --border-sand
    static let borderSandLight = Color(hex: 0xF0EDE8) // --border-sand-light

    // Texto
    static let textPrimary = Color(hex: 0x23201D)     // --text-primary
    static let textSecondary = Color(hex: 0x6B645C)   // --text-secondary
    static let textMuted = Color(hex: 0x9E968D)       // --text-muted

    // Acento terracota (marca)
    static let terracotta = Color(hex: 0xB85D36)       // --terracotta-primary
    static let terracottaHover = Color(hex: 0x943E1F)  // --terracotta-hover

    // Etiqueta de mesa
    static let tableTagBg = Color(hex: 0xF8ECE7)
    static let tableTagText = Color(hex: 0x943E1F)
    static let tableTagBorder = Color(hex: 0xF0D5C9)

    // Etiquetas de estado
    static let amberTagBg = Color(hex: 0xFEF9EE)
    static let amberTagBorder = Color(hex: 0xE8C88A)
    static let amberTagText = Color(hex: 0x965B0A)

    static let slateTagBg = Color(hex: 0xF1F5F9)
    static let slateTagBorder = Color(hex: 0xCBD5E1)
    static let slateTagText = Color(hex: 0x2C3E55)

    static let oliveTagBg = Color(hex: 0xF2F6F0)
    static let oliveTagBorder = Color(hex: 0xBDD4BA)
    static let oliveTagText = Color(hex: 0x2F4E2C)
    static let oliveButton = Color(hex: 0x3F623C)

    // Avisos de alergia
    static let alertPeachBg = Color(hex: 0xFDF4F2)
    static let alertPeachBorder = Color(hex: 0xF8C8C3)
    static let alertPeachText = Color(hex: 0x8A2C2A)

    // Neutrales heredados del prototipo Tailwind (zinc)
    static let ink = Color(hex: 0x18181B)
    static let inkSoft = Color(hex: 0x27272A)
    static let zinc100 = Color(hex: 0xF4F4F5)
    static let zinc200 = Color(hex: 0xE4E4E7)
    static let zinc300 = Color(hex: 0xD4D4D8)
    static let zinc400 = Color(hex: 0xA1A1AA)
    static let zinc500 = Color(hex: 0x71717A)
    static let zinc600 = Color(hex: 0x52525B)
    static let zinc700 = Color(hex: 0x3F3F46)
    static let zinc800 = Color(hex: 0x27272A)

    static let success = Color(hex: 0x059669)   // emerald-600
    static let successLight = Color(hex: 0x34D399)
    static let warningBar = Color(hex: 0xD97706) // ámbar de demora
    static let slateBar = Color(hex: 0x3B597B)

    static let progressRail = Color(hex: 0xE4E4E7)

    // MARK: Colores por estado de comanda

    /// Borde superior de las tarjetas KDS según estado.
    static func kdsAccent(for status: OrderStatus) -> Color {
        switch status {
        case .pending: return warningBar
        case .inProgress: return slateBar
        case .ready: return oliveButton
        case .delivered: return zinc200
        }
    }

    /// Borde general de la tarjeta (se vuelve ámbar si hay demora).
    static func kdsBorder(for order: KitchenOrder) -> Color {
        if order.status == .delivered { return zinc200 }
        return order.isDelayed() ? Color(hex: 0xFBBF24) : zinc200
    }

    /// Colores de la píldora de estado.
    static func statusPalette(for status: OrderStatus) -> (bg: Color, border: Color, text: Color) {
        switch status {
        case .pending: return (amberTagBg, amberTagBorder, amberTagText)
        case .inProgress: return (slateTagBg, slateTagBorder, slateTagText)
        case .ready: return (oliveTagBg, oliveTagBorder, oliveTagText)
        case .delivered: return (zinc100, zinc200, zinc600)
        }
    }
}

// MARK: - Tipografías

extension Font {
    /// Titulares y cuerpo (Inter → SF Pro por defecto del sistema).
    static func atelier(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Importes, códigos y etiquetas monoespaciadas (JetBrains Mono → SF Mono).
    static func atelierMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Utilidades de color

extension Color {
    /// Crea un color desde un literal hexadecimal (`0xB85D36`).
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Superficies reutilizables

/// Tarjeta blanca con borde arena, patrón base de todo el diseño.
struct SandCard<Content: View>: View {
    var padding: CGFloat = 14
    var cornerRadius: CGFloat = 10
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.borderSand, lineWidth: 1)
            )
    }
}

/// Etiqueta compacta tipo «píldora» usada en estados, mesas y avisos.
struct TagLabel: View {
    let text: String
    var background: Color
    var border: Color
    var foreground: Color
    var monospaced: Bool = true
    /// Fuerza mayúsculas (el prototipo solo lo hace en ciertas etiquetas).
    var uppercase: Bool = false

    var body: some View {
        Text(text)
            .font(monospaced ? .atelierMono(10, weight: .medium) : .atelier(10, weight: .medium))
            .textCase(uppercase ? .uppercase : nil)
            .foregroundStyle(foreground)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
    }
}

/// Botón principal oscuro (carbón) con texto e icono opcional.
struct PrimaryActionButton: View {
    let title: String
    var systemImage: String? = nil
    var trailingText: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.atelier(13, weight: .medium))
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                }
                Spacer(minLength: 0)
                if let trailingText {
                    Text(trailingText)
                        .font(.atelierMono(13, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Theme.ink)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }
}

/// Botón secundario con borde arena sobre fondo blanco.
struct SecondaryActionButton: View {
    let title: String
    var systemImage: String? = nil
    var tint: Color = Theme.zinc800
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(title)
                    .font(.atelier(12, weight: .semibold))
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Theme.zinc300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
