# webapp — Atelier Bistro (Carta Digital + SwiftUI)

Repositorio con **dos implementaciones** de la carta digital de *Atelier Bistro*,
originadas a partir del prototipo `stitch_smart_table_order_system.zip`:

| Implementación | Ruta | Estado |
|---|---|---|
| **Web app** (Hono + Cloudflare Pages) | `src/`, `public/` | ✅ Funcional, con búsqueda en tiempo real y vista de detalle |
| **App nativa iOS** (SwiftUI) | `atelier-bistro-ios/` | ✅ Código completo (compilar en Xcode) |

---

## 🌐 Web app — Carta Digital

Aplicación Hono que renderiza la carta en servidor y ofrece **búsqueda y
filtrado en tiempo real** y **vista de detalle** al pulsar cualquier plato.

### Funcionalidad

- **Búsqueda en tiempo real**: filtra al escribir, sin recargar ni llamar al
  servidor. Busca por nombre, descripción, categoría, etiquetas y **alérgenos**,
  ignorando acentos («salmon» encuentra «Salmón»).
- **Filtro por categoría**: chips de Entrantes, Principales, Brasa y Carnes,
  Postres y Bebidas, combinables con la búsqueda de texto.
- **Vista de detalle**: al pulsar cualquier ítem se abre una hoja con precio,
  disponibilidad, descripción, etiquetas, tiempo de elaboración, alérgenos y
  todas las **opciones de personalización** (obligatorias y opcionales).
  Se cierra con el botón, el fondo, `Esc` o el enlace permanente.
- **Estados de resultado**: contador de platos, estado vacío con botón para
  limpiar filtros y aviso «Agotado» en los platos no disponibles.
- **Sin JavaScript**: el listado se renderiza en servidor y cada plato tiene una
  página de detalle enlazable en `/item/:id`.

### Rutas

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/` | Carta completa (búsqueda y detalle en cliente) |
| `GET` | `/item/:id` | Página de detalle enlazable de un plato |
| `GET` | `/api/menu?q=&category=` | Listado filtrado en servidor (JSON) |
| `GET` | `/api/menu/:id` | Detalle de un plato con sus modificadores (JSON) |
| `GET` | `/api/categories` | Categorías disponibles (JSON) |

Ejemplos:

```bash
curl "http://localhost:3000/api/menu?q=trufa"
curl "http://localhost:3000/api/menu?q=lacteos"      # busca por alérgeno
curl "http://localhost:3000/api/menu?category=postres"
curl "http://localhost:3000/api/menu/p-3"
```

### Desarrollo

```bash
npm install
npm run build          # compila el Worker a dist/
pm2 start ecosystem.config.cjs   # wrangler pages dev dist --port 3000
```

La carta vive en `src/data/menu.ts` (fuente única de verdad): añadir un plato
ahí lo publica automáticamente en la lista, la búsqueda, la API y las páginas
de detalle.

### Estructura

```
src/
├── index.tsx            # Rutas: páginas y API
├── renderer.tsx         # Layout HTML (fuentes, CSS, metadatos)
├── data/menu.ts         # Carta, categorías, formato € y filtrado
└── views/menu.tsx       # Lista, tarjetas, detalle y página de detalle
public/static/
├── menu.js              # Búsqueda en vivo + apertura del detalle
└── style.css            # Tema gastronómico (lienzo cálido, terracota)
```

---

## 📱 App iOS (SwiftUI)

Conversión nativa completa del mismo prototipo: carta, personalización de platos,
carrito con propinas, división de cuenta, seguimiento de comanda en vivo y KDS de
cocina. Ver **`atelier-bistro-ios/README.md`** para el detalle.

```bash
cd atelier-bistro-ios
brew install xcodegen   # solo la primera vez
xcodegen generate
open AtelierBistro.xcodeproj
```

---

## 🎨 Diseño

Paleta «gastronomic-theme» del prototipo en ambas implementaciones: lienzo
`#FAF8F5`, borde arena `#E7E2DA`, texto `#23201D` y acento terracota `#B85D36`.
Importes en formato español (`€ 14,50`) con tipografía monoespaciada.

## 📊 Estado

- **Web**: Hono 4 · Cloudflare Pages · TypeScript. Build ✅ y flujo verificado
  en navegador (búsqueda, filtros, detalle, página `/item/:id`).
- **iOS**: SwiftUI · iOS 16+ · Swift 5.9. Pendiente de compilar en Xcode/macOS.
