//
//  SheetContainer.swift
//  AtelierBistro
//
//  Contenedor común de las capas modales: hoja blanca anclada al pie
//  con esquinas superiores redondeadas, igual que los drawers del prototipo.
//

import SwiftUI

struct SheetContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Theme.zinc300)
                .frame(width: 34, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 4)

            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.surface)
        .clipShape(
            TopRoundedRectangle(radius: 16)
        )
        .shadow(color: .black.opacity(0.18), radius: 18, y: -6)
    }
}

/// Rectángulo con las esquinas superiores redondeadas y las inferiores rectas.
/// Sustituye a `UnevenRoundedRectangle` para admitir iOS 16.0.
struct TopRoundedRectangle: Shape {
    var radius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clamped = min(radius, min(rect.width, rect.height) / 2)

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + clamped))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + clamped, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - clamped, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + clamped),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

/// Barra de progreso fina usada en el estado de cobro de la mesa.
struct ProgressRail: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.progressRail)

                Capsule()
                    .fill(Theme.ink)
                    .frame(width: max(0, min(1, progress)) * geometry.size.width)
            }
        }
        .frame(height: 6)
    }
}
