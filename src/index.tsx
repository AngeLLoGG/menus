import { Hono } from 'hono'
import { renderer } from './renderer'
import { ALL_CATEGORY, categories, filterMenu, getItem, menu } from './data/menu'
import { DetailPage, MenuPage, toClientItem } from './views/menu'

const app = new Hono()

app.use(renderer)

/**
 * Carta completa. Se renderizan todos los platos y el filtrado en tiempo real
 * lo resuelve el cliente sobre el propio DOM (sin recargar la página).
 */
app.get('/', (c) => {
  const query = c.req.query('q') ?? ''
  const category = c.req.query('category') ?? ALL_CATEGORY
  const payload = menu.map(toClientItem)

  return c.render(<MenuPage items={menu} payload={payload} query={query} category={category} />, {
    title: 'Carta Digital · Atelier Bistro'
  })
})

/**
 * API de listado con filtrado en servidor.
 * Ejemplos: /api/menu?q=trufa  ·  /api/menu?category=postres
 */
app.get('/api/menu', (c) => {
  const query = c.req.query('q') ?? ''
  const category = c.req.query('category') ?? ALL_CATEGORY

  const items = filterMenu(menu, { q: query, category })

  return c.json({
    query: { q: query, category },
    count: items.length,
    items: items.map(toClientItem)
  })
})

/** Categorías disponibles. */
app.get('/api/categories', (c) => {
  return c.json({ categories })
})

/** Detalle de un plato, con sus grupos de modificadores. */
app.get('/api/menu/:id', (c) => {
  const item = getItem(c.req.param('id'))

  if (!item) {
    return c.json({ error: 'not_found', message: 'Plato no encontrado' }, 404)
  }

  return c.json({ item: toClientItem(item) })
})

/** Página de detalle enlazable (y respaldo sin JavaScript). */
app.get('/item/:id', (c) => {
  const item = getItem(c.req.param('id'))

  if (!item) {
    return c.notFound()
  }

  return c.render(<DetailPage item={item} />, {
    title: `${item.name} · Atelier Bistro`
  })
})

export default app
