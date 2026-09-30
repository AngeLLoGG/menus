# Atelier Bistro · Smart Table Order & KDS (SwiftUI)

Conversión a **SwiftUI** del prototipo HTML `stitch_smart_table_order_system.zip`
(Smart Table Order & Pay + KDS Cocina). Se ha portado la interfaz **y** toda la
lógica del prototipo: carta con modificadores, carrito, propinas, división de
cuenta, seguimiento de comanda en vivo y el tablero de cocina.

---

## 1. Estado de la conversión

| Bloque del prototipo | Estado | Archivo SwiftUI |
|---|---|---|
| Barra superior con selector de vistas (Dual / Comensal / KDS) | ✅ | `App/WorkspaceView.swift` |
| Vista Comensal (marco móvil, cabecera, buscador, categorías) | ✅ | `Customer/CustomerView.swift` |
| Carta con precios, platos agotados y botón Personalizar/Añadir | ✅ | `Customer/CustomerView.swift` |
| Banner de comanda activa | ✅ | `Customer/CustomerView.swift` |
| Modal de personalización (radio/checkbox, nota, cantidad, total) | ✅ | `Sheets/ProductConfigSheet.swift` |
| Drawer del carrito con líneas, notas y eliminación | ✅ | `Sheets/CartSheet.swift` |
| Selector de propina (0/5/10/15 % + importe libre) | ✅ | `Sheets/CartSheet.swift` |
| División de cuenta (partes iguales / por ítems) | ✅ | `Sheets/SplitBillSheet.swift` |
| Ticket de seguimiento en vivo con stepper y facturación | ✅ | `Sheets/TicketSheet.swift` |
| KDS Cocina (filtros, tarjetas, avance de estado, demoras) | ✅ | `KDS/KitchenDisplayView.swift` |
| Persistencia de la comanda activa | ✅ (`UserDefaults`) | `Store/AppStore.swift` |

### Adaptaciones respecto al HTML

El prototipo era una maqueta de escritorio con un marco de smartphone simulado.
La conversión a SwiftUI mantiene esa idea cuando hay espacio y se adapta a iPhone:

- **iPad / pantallas anchas** → vista **Dual** real: comensal dentro de un marco de
  móvil a la izquierda y KDS a la derecha, igual que el mock.
- **iPhone (compacto)** → vista de **Comensal** a pantalla completa; el KDS queda
  accesible desde el selector segmentado de la barra superior.
- Los modales apilados del prototipo (p. ej. carrito → dividir cuenta) se
  reproducen con una **pila de capas** (`AppStore.overlays`), de modo que al cerrar
  la superior reaparece la inferior, respetando el *z-index* original.
- Sustituciones idiomáticas: `alert()` → alerta nativa, `localStorage` →
  `UserDefaults`, `setInterval` → `TimelineView`, `onclick` → `Button`.

---

## 2. Requisitos y puesta en marcha

- **Xcode 15 o superior**, **iOS 16.0+** (iPhone y iPad).
- El proyecto se define con [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen        # solo la primera vez
cd atelier-bistro-ios
xcodegen generate            # crea AtelierBistro.xcodeproj
open AtelierBistro.xcodeproj
```

También puede crearse un proyecto vacío en Xcode y arrastrar la carpeta
`AtelierBistro/` (los archivos no dependen de configuración especial).

> `AtelierBistro/Info.plist` lo genera XcodeGen a partir de `project.yml`;
> no editar por separado para no crear dos fuentes de verdad.

---

## 3. Estructura del código

```
atelier-bistro-ios/
├── project.yml                       # Definición del proyecto (XcodeGen)
├── README.md
└── AtelierBistro/
    ├── App/
    │   ├── AtelierBistroApp.swift    # @main + inyección del AppStore
    │   └── WorkspaceView.swift       # Barra superior, layout adaptativo, capas modales
    ├── Models/
    │   ├── Models.swift              # Product, CartItem, KitchenOrder, totales, formato €
    │   └── SampleData.swift          # Carta completa, modificadores y comandas iniciales
    ├── Store/
    │   └── AppStore.swift            # Estado reactivo, lógica de negocio y persistencia
    ├── Theme/
    │   └── Theme.swift               # Paleta «gastronomic-theme», tipografías y componentes
    ├── Customer/
    │   └── CustomerView.swift        # Carta digital del comensal
    ├── Sheets/
    │   ├── ProductConfigSheet.swift  # Personalización de plato
    │   ├── CartSheet.swift           # Resumen de comanda + propina
    │   ├── SplitBillSheet.swift      # Dividir cuenta
    │   └── TicketSheet.swift         # Seguimiento en vivo
    ├── KDS/
    │   └── KitchenDisplayView.swift  # Tablero de cocina
    ├── Components/
    │   └── SheetContainer.swift      # Contenedor de hojas y barra de progreso
    └── Assets.xcassets/              # AppIcon, AccentColor, color de lanzamiento
```

---

## 4. Modelo de datos

```
MenuCategory ─1:N─ Product ─1:N─ ModifierGroup ─1:N─ ModifierOption
CartItem (producto + modificadores elegidos + nota + cantidad)
KitchenOrder (mesa, estado, aviso, KitchenItem[], subtotal, propina)
OrderStatus: pending → in_progress → ready → delivered
SplitDataset (carrito | comanda activa | demo) · SplitMode: equal | items
OrderTotals (subtotal bruto, base imponible, IVA 10 %, propina, total)
```

**Reglas de negocio portadas del prototipo:**

- El precio de la carta **ya incluye el 10 % de IVA**; el desglose lo extrae
  (`baseSubtotal = subtotal / 1.10`).
- Propina por porcentaje o importe fijo; en el reparto por ítems se aplica de
  forma **proporcional** al consumo de cada comensal.
- Los avisos de alergia se muestran destacados en rojo y las comandas que superan
  **15 minutos** se marcan en ámbar con la etiqueta «Demora».
- Al confirmar el pedido se genera un código `AT-###`, la comanda entra en el KDS
  como *pendiente* y se abre el ticket de seguimiento. El carrito se vacía.
- Estado inicial del KDS idéntico al mock: mesas 02 (17 m), 07 (9 m) y 11 (4 m).

---

## 5. Guía de uso

1. **Elegir plato**: en «Carta Digital», pulsa *Personalizar* (o *Añadir* en platos
   sin opciones). Marca aderezo, complementos y añade instrucciones para cocina.
2. **Revisar la comanda**: el carrito muestra líneas, notas y el desglose con IVA.
3. **Propina**: elige 0/5/10/15 % o escribe un importe libre; *Limpiar* la resetea.
4. **Dividir cuenta**: partes iguales (2–12 comensales, con registro de pagos de la
   mesa) o por ítems, seleccionando tus platos.
5. **Pedir y enviar**: la comanda aparece al instante en el KDS y se abre el ticket.
6. **Seguimiento**: el stepper avanza con *+ Siguiente Estado*; los cambios se
   reflejan también en la tarjeta del KDS.
7. **KDS Cocina**: filtra por estado, avanza comandas con *Empezar Preparación* →
   *Marcar Listo* → *Servido / Entregar*, archiva las entregadas y usa
   *+ Nueva Comanda* para inyectar una comanda de prueba.

---

## 6. Detalles de fidelidad visual

- Paleta exacta del prototipo: lienzo `#FAF8F5`, borde arena `#E7E2DA`, texto
  `#23201D`, naranja terracota `#B85D36`, acentos de estado ámbar/pizarra/oliva.
- Tipografía: sistema para texto y **monoespaciada** para importes, códigos y
  etiquetas (sustituye a Inter / JetBrains Mono del CDN).
- Formatos en español: `€ 14,50`, hora `14:32`, mesas `04`.
- Franjas superiores de color por estado en las tarjetas del KDS y borde ámbar
  cuando hay demora.

---

## 7. Pendiente / posibles siguientes pasos

- Sustituir `SampleData` por una API real de comandas (el `AppStore` ya concentra
  los puntos de integración).
- Comandas nuevas **en vivo** desde cocina (hoy se simulan con `+ Nueva Comanda`).
- Autenticación de mesa por QR y bloqueo de la comanda una vez enviada.
- Sincronización entre dispositivos (hoy la comanda activa es local al dispositivo).
- Tests unitarios de `OrderTotals`, reparto de cuenta y transiciones de estado.
- Localización (hoy los textos están en español, como el original).

---

## 8. Origen

Conversión del prototipo `stitch_smart_table_order_system.zip`
(`code.html` + `screen.png`), restaurante ficticio *Atelier Bistro*.
