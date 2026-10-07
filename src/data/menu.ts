/**
 * Carta de Atelier Bistro.
 *
 * Fuente única de verdad del menú: la consumen tanto las rutas de la API
 * (`/api/menu`, `/api/menu/:id`) como el render inicial de la página.
 */

export type ModifierOption = {
  id: string
  name: string
  /** Suplemento en euros. `0` se muestra como «Incluido». */
  price: number
}

export type ModifierGroup = {
  id: string
  name: string
  required: boolean
  type: 'single' | 'multiple'
  options: ModifierOption[]
}

export type MenuItem = {
  id: string
  name: string
  category: string
  description: string
  price: number
  available: boolean
  /** Etiquetas comerciales (picante, vegano...). */
  tags: string[]
  /** Alérgenos declarados; se incluyen en la búsqueda. */
  allergens: string[]
  /** Tiempo estimado de elaboración, en minutos. */
  prepTime: number
  modifiers: ModifierGroup[]
}

export type Category = {
  id: string
  name: string
}

/** Categoría comodín que agrupa todas las secciones. */
export const ALL_CATEGORY = 'all'

export const categories: Category[] = [
  { id: ALL_CATEGORY, name: 'Todo' },
  { id: 'entrantes', name: 'Entrantes' },
  { id: 'principales', name: 'Principales' },
  { id: 'carnes', name: 'Brasa y Carnes' },
  { id: 'postres', name: 'Postres' },
  { id: 'bebidas', name: 'Bebidas & Vinos' }
]

export const menu: MenuItem[] = [
  {
    id: 'p-1',
    name: 'Tartar de Salmón & Aguacate',
    category: 'entrantes',
    description:
      'Salmón fresco noruego picado a cuchillo, emulsión de cítricos, cebolleta y sésamo negro tostado.',
    price: 14.5,
    available: true,
    tags: ['Del mar', 'Sin gluten'],
    allergens: ['Pescado', 'Sésamo', 'Soja'],
    prepTime: 12,
    modifiers: [
      {
        id: 'mod-dressing',
        name: 'Aderezo Cítrico',
        required: true,
        type: 'single',
        options: [
          { id: 'opt-d1', name: 'Ponzu y Lima (Recomendado)', price: 0 },
          { id: 'opt-d2', name: 'Aceite de Oliva Virgen Extra & Sal marina', price: 0 },
          { id: 'opt-d3', name: 'Picante suave de Chiles Fermentados', price: 0.5 }
        ]
      },
      {
        id: 'mod-extras-salmon',
        name: 'Complementos',
        required: false,
        type: 'multiple',
        options: [
          { id: 'opt-e1', name: 'Extra de Tostas finas de centeno (4 uds)', price: 1.5 },
          { id: 'opt-e2', name: 'Alcaparras fritas crujientes', price: 0.8 },
          { id: 'opt-e3', name: 'Doble ración de Aguacate hass', price: 2 }
        ]
      }
    ]
  },
  {
    id: 'p-2',
    name: 'Burrata de Puglia & Higos Confitados',
    category: 'entrantes',
    description:
      'Burrata artesanal de 200g, higos al vino dulce, rúcula salvaje y reducción balsámica de Módena de 12 años.',
    price: 13,
    available: true,
    tags: ['Vegetariano'],
    allergens: ['Lácteos', 'Sulfitos', 'Gluten'],
    prepTime: 10,
    modifiers: [
      {
        id: 'mod-burrata-bread',
        name: 'Acompañamiento de Pan',
        required: true,
        type: 'single',
        options: [
          { id: 'opt-b1', name: 'Focaccia artesanal de romero', price: 0 },
          { id: 'opt-b2', name: 'Pan de masa madre tostado', price: 0 },
          { id: 'opt-b3', name: 'Sin gluten (tostadas de maíz)', price: 1 }
        ]
      },
      {
        id: 'mod-burrata-extras',
        name: 'Añadidos Gourmet',
        required: false,
        type: 'multiple',
        options: [
          { id: 'opt-be1', name: 'Láminas de Jamón Ibérico de Bellota (50g)', price: 4.5 },
          { id: 'opt-be2', name: 'Pesto de albahaca fresca casero', price: 1.5 }
        ]
      }
    ]
  },
  {
    id: 'p-3',
    name: 'Risotto de Boletus & Trufa Negra',
    category: 'principales',
    description:
      'Arroz Carnaroli mantecado con Parmigiano Reggiano 24 meses, boletus edulis salteados y perlas de trufa melanosporum.',
    price: 18.5,
    available: true,
    tags: ['Vegetariano', 'De temporada'],
    allergens: ['Lácteos', 'Sulfitos'],
    prepTime: 22,
    modifiers: [
      {
        id: 'mod-risotto-cheese',
        name: 'Punto de Parmigiano',
        required: true,
        type: 'single',
        options: [
          { id: 'opt-r1', name: 'Tradicional mantecado', price: 0 },
          { id: 'opt-r2', name: 'Poco queso / Ligero', price: 0 }
        ]
      },
      {
        id: 'mod-risotto-extras',
        name: 'Extras',
        required: false,
        type: 'multiple',
        options: [
          { id: 'opt-re1', name: 'Láminas de trufa negra fresca de temporada', price: 5 },
          { id: 'opt-re2', name: 'Foie micuit marcado a la plancha', price: 4 }
        ]
      }
    ]
  },
  {
    id: 'p-4',
    name: 'Lubina Salvaje a la Espalda',
    category: 'principales',
    description:
      'Lomo de lubina salvaje confitada a baja temperatura, bilbaína clásica suave de ajo y emulsión de patata ratte.',
    price: 22,
    available: true,
    tags: ['Del mar', 'Sin gluten'],
    allergens: ['Pescado', 'Lácteos'],
    prepTime: 20,
    modifiers: [
      {
        id: 'mod-fish-cook',
        name: 'Punto de Cocción',
        required: true,
        type: 'single',
        options: [
          { id: 'opt-fc1', name: 'Punto jugoso (Recomendado)', price: 0 },
          { id: 'opt-fc2', name: 'Bien cocido', price: 0 }
        ]
      }
    ]
  },
  {
    id: 'p-5',
    name: 'Solomillo de Vaca Madurada (250g)',
    category: 'carnes',
    description:
      'Corte seleccionado de vaca frisona con 45 días de maduración dry-aged, cristales de sal Maldon y chalotas glaseadas.',
    price: 26.5,
    available: true,
    tags: ['A la brasa', 'Sin gluten'],
    allergens: ['Lácteos', 'Mostaza'],
    prepTime: 25,
    modifiers: [
      {
        id: 'mod-meat-doneness',
        name: 'Término de la Carne',
        required: true,
        type: 'single',
        options: [
          { id: 'opt-m1', name: 'Poco hecho (Bleu)', price: 0 },
          { id: 'opt-m2', name: 'Al punto (Medium rare)', price: 0 },
          { id: 'opt-m3', name: 'Punto más (Medium well)', price: 0 },
          { id: 'opt-m4', name: 'Muy hecho', price: 0 }
        ]
      },
      {
        id: 'mod-meat-garnish',
        name: 'Guarnición Principal',
        required: true,
        type: 'single',
        options: [
          { id: 'opt-g1', name: 'Patatas baby asadas con romero', price: 0 },
          { id: 'opt-g2', name: 'Pimientos del piquillo confitados a leña', price: 1 },
          { id: 'opt-g3', name: 'Ensalada de brotes y vinagreta de mostaza antigua', price: 0 }
        ]
      },
      {
        id: 'mod-meat-sauce',
        name: 'Salsas Artesanales',
        required: false,
        type: 'multiple',
        options: [
          { id: 'opt-s1', name: 'Salsa de pimienta verde de Madagascar', price: 1.8 },
          { id: 'opt-s2', name: 'Mantequilla Café de París especiada', price: 2 }
        ]
      }
    ]
  },
  {
    id: 'p-6',
    name: 'Costillar Ibérico Glaseado',
    category: 'carnes',
    description:
      'Costillas de cerdo ibérico cocidas durante 18 horas a baja temperatura con glaseado de miel de brezo y tomillo silvestre.',
    price: 19.5,
    available: false,
    tags: ['A la brasa'],
    allergens: ['Sulfitos'],
    prepTime: 18,
    modifiers: []
  },
  {
    id: 'p-7',
    name: 'Cremoso de Chocolate 70% & Sal de Añana',
    category: 'postres',
    description:
      'Ganache aireada de cacao ecológico origen Guanaja, núcleo líquido de avellana piamontesa y AOVE arbequina.',
    price: 7.5,
    available: true,
    tags: ['Vegetariano', 'Dulce'],
    allergens: ['Lácteos', 'Huevo', 'Frutos secos', 'Soja'],
    prepTime: 8,
    modifiers: [
      {
        id: 'mod-dessert-icecream',
        name: 'Bola de Helado Artesano',
        required: false,
        type: 'single',
        options: [
          { id: 'opt-i0', name: 'Sin helado adicional', price: 0 },
          { id: 'opt-i1', name: 'Helado de Vainilla bourbon de Madagascar', price: 2 },
          { id: 'opt-i2', name: 'Sorbete de Frambuesa silvestre', price: 2 }
        ]
      }
    ]
  },
  {
    id: 'p-8',
    name: 'Vino Tinto Ribera del Duero Crianza (Copa)',
    category: 'bebidas',
    description:
      '100% Tempranillo, 14 meses en barrica de roble francés. Notas de frutos negros maduros y cedro.',
    price: 4.8,
    available: true,
    tags: ['Vinos', 'Sin gluten'],
    allergens: ['Sulfitos'],
    prepTime: 2,
    modifiers: []
  },
  {
    id: 'p-9',
    name: 'Agua Mineral de Manantial (750ml)',
    category: 'bebidas',
    description:
      'Botella de vidrio retornable, agua de mineralización muy débil de origen alpino.',
    price: 3.2,
    available: true,
    tags: ['Sin gluten', 'Vegano'],
    allergens: [],
    prepTime: 1,
    modifiers: [
      {
        id: 'mod-water-type',
        name: 'Tipo de Agua',
        required: true,
        type: 'single',
        options: [
          { id: 'opt-w1', name: 'Natural sin gas (Fría)', price: 0 },
          { id: 'opt-w2', name: 'Natural sin gas (Tiempo)', price: 0 },
          { id: 'opt-w3', name: 'Con gas carbónico fino natural', price: 0.3 }
        ]
      }
    ]
  }
]

/** Importes en formato español: `€ 14,50`. */
const decimalFormatter = new Intl.NumberFormat('es-ES', {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2
})

export function formatPrice(value: number): string {
  return `€ ${decimalFormatter.format(value)}`
}

export function categoryName(categoryId: string): string {
  return categories.find((category) => category.id === categoryId)?.name ?? 'Plato'
}

/** Índice por id para resolver el detalle en tiempo constante. */
const menuById = new Map(menu.map((item) => [item.id, item]))

export function getItem(id: string): MenuItem | undefined {
  return menuById.get(id)
}

export type MenuFilter = {
  q?: string
  category?: string
}

/**
 * Filtrado del menú por texto libre y categoría.
 *
 * El texto se compara contra nombre, descripción, categoría, etiquetas y
 * alérgenos, ignorando acentos y mayúsculas, para que «salmon» encuentre
 * «Salmón».
 */
export function filterMenu(items: MenuItem[], filter: MenuFilter = {}): MenuItem[] {
  const query = normalize(filter.q ?? '')
  const category = filter.category ?? ALL_CATEGORY

  return items.filter((item) => {
    if (category !== ALL_CATEGORY && item.category !== category) return false
    if (!query) return true

    const haystack = normalize(
      [
        item.name,
        item.description,
        categoryName(item.category),
        item.tags.join(' '),
        item.allergens.join(' ')
      ].join(' ')
    )

    // Todas las palabras escritas deben aparecer en algún campo.
    return query.split(/\s+/).every((term) => haystack.includes(term))
  })
}

/** Minúsculas y sin diacríticos, para búsquedas tolerantes. */
export function normalize(value: string): string {
  return value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim()
}
