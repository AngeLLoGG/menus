import type { FC } from 'hono/jsx'
import type { MenuItem, ModifierGroup } from '../data/menu'
import { ALL_CATEGORY, categories, categoryName, formatPrice, normalize } from '../data/menu'

/** Datos que se envían al navegador para el filtrado instantáneo y el detalle. */
export type ClientMenuItem = {
  id: string
  name: string
  category: string
  categoryName: string
  description: string
  price: number
  priceLabel: string
  available: boolean
  tags: string[]
  allergens: string[]
  prepTime: number
  /** Se incluyen para que el detalle se abra al instante, sin otra petición. */
  modifiers: ModifierGroup[]
}

export function toClientItem(item: MenuItem): ClientMenuItem {
  return {
    id: item.id,
    name: item.name,
    category: item.category,
    categoryName: categoryName(item.category),
    description: item.description,
    price: item.price,
    priceLabel: formatPrice(item.price),
    available: item.available,
    tags: item.tags,
    allergens: item.allergens,
    prepTime: item.prepTime,
    modifiers: item.modifiers
  }
}

/** Texto indexado en el cliente para la búsqueda en tiempo real. */
function searchHaystack(item: MenuItem): string {
  return normalize(
    [
      item.name,
      item.description,
      categoryName(item.category),
      item.tags.join(' '),
      item.allergens.join(' ')
    ].join(' ')
  )
}

// MARK: - Tarjeta de la lista

export const MenuItemCard: FC<{ item: MenuItem }> = ({ item }) => {
  return (
    <button
      type="button"
      class={`menu-card${item.available ? '' : ' is-unavailable'}`}
      data-id={item.id}
      data-category={item.category}
      data-search={searchHaystack(item)}
      aria-label={`Ver detalle de ${item.name}`}
    >
      <div class="card-top">
        <h3 class="card-name">{item.name}</h3>
        {!item.available && <span class="card-badge">Agotado</span>}
      </div>

      <p class="card-desc">{item.description}</p>

      <div class="card-foot">
        <span class="card-price">{formatPrice(item.price)}</span>
        <span class="card-cta">
          Ver detalle
          <svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <polyline points="9 18 15 12 9 6" />
          </svg>
        </span>
      </div>
    </button>
  )
}

// MARK: - Página principal

type MenuPageProps = {
  items: MenuItem[]
  payload: ClientMenuItem[]
  query: string
  category: string
}

export const MenuPage: FC<MenuPageProps> = ({ items, payload, query, category }) => {
  const sections = categories.filter((entry) => entry.id !== ALL_CATEGORY)

  return (
    <>
      <header class="site-header">
        <div class="brand">
          <span class="brand-mark">S</span>
          <div class="brand-text">
            <span class="brand-name">ATELIER</span>
            <span class="brand-sub">v2.5 / Carta Digital</span>
          </div>
        </div>
        <span class="header-table">Mesa 04</span>
      </header>

      <main class="page">
        <div class="page-intro">
          <p class="eyebrow">Atelier Bistro</p>
          <h1 class="page-title">Nuestra Carta</h1>
          <p class="page-subtitle">
            Busca en tiempo real por plato, ingrediente o alérgeno. Pulsa cualquier plato para ver su detalle.
          </p>
        </div>

        <form class="search-field" role="search" action="/" method="get" id="search-form">
          <span class="search-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
          </span>
          <input
            id="search-input"
            class="search-input"
            type="text"
            name="q"
            value={query}
            placeholder="Buscar por plato, ingrediente, alérgeno..."
            autocomplete="off"
            spellcheck={false}
            inputmode="search"
          />
          <button type="button" class="search-clear" id="clear-search" aria-label="Limpiar búsqueda" hidden>
            <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </form>

        <nav class="chips" id="category-chips" aria-label="Filtrar por categoría">
          {categories.map((entry) => (
            <button
              type="button"
              class={`chip${entry.id === category ? ' is-active' : ''}`}
              data-category={entry.id}
              aria-pressed={entry.id === category ? 'true' : 'false'}
            >
              {entry.name}
            </button>
          ))}
        </nav>

        <div class="results-bar">
          <span class="results-count" id="results-count" aria-live="polite">
            {items.length} platos disponibles
          </span>
        </div>

        <div id="menu-list">
          {sections.map((section) => {
            const sectionItems = items.filter((item) => item.category === section.id)
            if (sectionItems.length === 0) return null

            return (
              <section class="menu-section" data-section-category={section.id} key={section.id}>
                <div class="section-header">
                  <h2 class="section-title">{section.name}</h2>
                  <span class="section-count">{sectionItems.length}</span>
                </div>
                <div class="menu-grid">
                  {sectionItems.map((item) => (
                    <MenuItemCard item={item} key={item.id} />
                  ))}
                </div>
              </section>
            )
          })}
        </div>

        <div class="empty-state" id="empty-state" hidden>
          <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <p class="empty-title">Sin resultados</p>
          <p class="empty-copy">No hay platos que coincidan con tu búsqueda.</p>
          <button type="button" class="empty-reset" id="reset-filters">Limpiar filtros</button>
        </div>
      </main>

      <footer class="site-footer">
        <span>IVA incluido · Servicio directo a mesa</span>
        <span class="footer-dot">·</span>
        <a class="footer-link" href="/api/menu">API del menú</a>
      </footer>

      {/* Detalle: capa modal rellenada por el cliente */}
      <div class="detail-overlay" id="detail-overlay" hidden>
        <div class="detail-backdrop" data-close></div>
        <div class="detail-sheet" role="dialog" aria-modal="true" aria-labelledby="detail-title">
          <div class="detail-head">
            <div class="detail-heading">
              <p class="detail-eyebrow" id="detail-eyebrow"></p>
              <h2 class="detail-title" id="detail-title"></h2>
            </div>
            <button type="button" class="detail-close" id="detail-close" aria-label="Cerrar detalle" data-close>
              <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                <line x1="18" y1="6" x2="6" y2="18" />
                <line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          </div>
          <div class="detail-body" id="detail-body"></div>
        </div>
      </div>

      <script
        id="menu-payload"
        type="application/json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(payload).replace(/</g, '\\u003c') }}
      />
      <script src="/static/menu.js" defer />
    </>
  )
}

// MARK: - Página de detalle (enlace directo / sin JavaScript)

export const DetailPage: FC<{ item: MenuItem }> = ({ item }) => {
  return (
    <>
      <header class="site-header">
        <div class="brand">
          <span class="brand-mark">S</span>
          <div class="brand-text">
            <span class="brand-name">ATELIER</span>
            <span class="brand-sub">v2.5 / Carta Digital</span>
          </div>
        </div>
        <span class="header-table">Mesa 04</span>
      </header>

      <main class="page">
        <a class="back-link" href="/">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <polyline points="15 18 9 12 15 6" />
          </svg>
          Volver a la carta
        </a>

        <article class="detail-static">
          <p class="eyebrow">{categoryName(item.category)}</p>
          <h1 class="page-title">{item.name}</h1>

          <div class="detail-price-row">
            <span class="detail-price">{formatPrice(item.price)}</span>
            {item.available ? (
              <span class="detail-badge is-ok">Disponible</span>
            ) : (
              <span class="detail-badge is-off">Agotado</span>
            )}
          </div>

          <p class="detail-desc">{item.description}</p>

          {item.tags.length > 0 && (
            <div class="detail-tags">
              {item.tags.map((tag) => (
                <span class="tag" key={tag}>
                  {tag}
                </span>
              ))}
            </div>
          )}

          <dl class="detail-meta">
            <div class="meta-item">
              <dt class="meta-label">Tiempo de elaboración</dt>
              <dd class="meta-value">{item.prepTime} min</dd>
            </div>
            <div class="meta-item">
              <dt class="meta-label">Alérgenos</dt>
              <dd class="meta-value">{item.allergens.length > 0 ? item.allergens.join(', ') : 'Ninguno declarado'}</dd>
            </div>
          </dl>

          {item.modifiers.length > 0 && (
            <section class="detail-block">
              <h2 class="detail-block-title">Opciones de personalización</h2>
              {item.modifiers.map((group) => (
                <div class="mod-group" key={group.id}>
                  <div class="mod-group-head">
                    <span class="mod-name">{group.name}</span>
                    <span class="mod-flag">{group.required ? 'Obligatorio' : 'Opcional'}</span>
                  </div>
                  <ul class="mod-options">
                    {group.options.map((option) => (
                      <li class="mod-option" key={option.id}>
                        <span class="mod-option-name">{option.name}</span>
                        <span class="mod-option-price">
                          {option.price > 0 ? `+${formatPrice(option.price)}` : 'Incluido'}
                        </span>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </section>
          )}
        </article>
      </main>

      <footer class="site-footer">
        <span>IVA incluido · Servicio directo a mesa</span>
        <span class="footer-dot">·</span>
        <a class="footer-link" href="/api/menu/{item.id}">Ver como JSON</a>
      </footer>
    </>
  )
}
