//
//  AtelierBistroApp.swift
//  AtelierBistro
//
//  Sistema Smart Table Order & KDS · Atelier Bistro
//  Pedido en mesa desde el móvil del comensal y tablero de cocina
//  sincronizado, con propinas y división de cuenta.
//

import SwiftUI

@main
@MainActor
struct AtelierBistroApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            WorkspaceView()
                .environmentObject(store)
                .tint(Theme.terracotta)
                .preferredColorScheme(.light)
        }
    }
}
