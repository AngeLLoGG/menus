# webapp — Conversión de Stitch a SwiftUI

Este workspace contiene la **conversión a SwiftUI** del prototipo HTML
`stitch_smart_table_order_system.zip` (*Smart Table Order & Pay + KDS Cocina*,
restaurante ficticio «Atelier Bistro»).

## 📁 Contenido

| Ruta | Descripción |
|---|---|
| **`atelier-bistro-ios/`** | **Proyecto SwiftUI completo (iOS 16+, iPhone y iPad)** |
| `atelier-bistro-ios/README.md` | Documentación detallada de la app: arquitectura, datos y guía de uso |
| `/home/user/stitch_extract/` | Prototipo original de referencia (`code.html` + `screen.png`) |

> El template Hono/Cloudflare preexistente (`src/`, `public/`, `wrangler.jsonc`)
> se conserva sin usar: esta conversión es una app **nativa SwiftUI**, no una web.

## 🚀 Cómo abrir el proyecto iOS

```bash
cd atelier-bistro-ios
brew install xcodegen     # solo la primera vez
xcodegen generate
open AtelierBistro.xcodeproj
```

Alternativa: crear un proyecto iOS vacío en Xcode y arrastrar la carpeta
`AtelierBistro/`.

## ✅ Funcionalidad convertida

- **Carta digital del comensal**: buscador, filtros por categoría, platos
  agotados, precios en formato europeo.
- **Personalización de platos**: grupos obligatorios (selección única) y
  opcionales (múltiple) con suplementos, nota para cocina, cantidad y total en
  tiempo real.
- **Carrito y propinas**: líneas con modificadores y notas, propina 0/5/10/15 %
  o importe libre, desglose con IVA 10 % incluido.
- **División de cuenta**: partes iguales (2–12 comensales, con registro de pagos)
  o pago por ítems con propina proporcional.
- **Seguimiento en vivo**: stepper de 4 estados, ticket digital con facturación y
  simulador de avance.
- **KDS Cocina**: filtros por estado, tarjetas con avisos de alergia, cronómetros,
  alertas de demora > 15 min y avance del flujo de preparación.

## 🎨 Diseño

Se ha replicado la paleta «gastronomic-theme» del original (lienzo `#FAF8F5`,
borde arena `#E7E2DA`, terracota `#B85D36`), tipografía monoespaciada para
importes y códigos, y los formatos en español (`€ 14,50`, mesas `04`).

**Adaptación a iOS:** en iPad se muestra la *vista dual* (móvil + KDS) como en el
mock; en iPhone la carta ocupa la pantalla y el KDS se alcanza desde el selector
superior. Los modales apilados del prototipo se reproducen con una pila de capas.

## 📊 Estado

- **Plataforma**: iOS 16.0+ (iPhone / iPad) · SwiftUI · Swift 5.9
- **Persistencia**: `UserDefaults` (comanda activa)
- **Datos**: catálogo y comandas de ejemplo en `SampleData.swift`
- **Compilación**: pendiente de verificar en Xcode/macOS (el sandbox Linux no
  dispone de toolchain de Swift para iOS)
