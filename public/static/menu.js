/**
 * Carta digital de Atelier Bistro.
 *
 * - Filtrado y búsqueda en tiempo real sobre la lista ya renderizada.
 * - Vista de detalle al pulsar cualquier plato.
 *
 * Sin dependencias: se ejecuta directamente en el navegador.
 */
;(function () {
  'use strict'

  // MARK: - Referencias del DOM

  var searchInput = document.getElementById('search-input')
  var clearButton = document.getElementById('clear-search')
  var resetButton = document.getElementById('reset-filters')
  var chipsContainer = document.getElementById('category-chips')
  var resultsCount = document.getElementById('results-count')
  var emptyState = document.getElementById('empty-state')
  var listContainer = document.getElementById('menu-list')
  var overlay = document.getElementById('detail-overlay')

  if (!searchInput || !listContainer) return

  // MARK: - Datos

  var payloadNode = document.getElementById('menu-payload')
  var itemsById = {}

  try {
    var items = JSON.parse(payloadNode ? payloadNode.textContent : '[]')
    items.forEach(function (item) {
      itemsById[item.id] = item
    })
  } catch (error) {
    console.warn('No se pudo leer el menú embebido:', error)
  }

  var TOTAL_ITEMS = Object.keys(itemsById).length
  var activeCategory = 'all'

  /**
   * Normaliza texto: minúsculas y sin acentos, para que «salmon» encuentre
   * «Salmón». Debe coincidir con la normalización del servidor.
   */
  function normalize(value) {
    return (value || '')
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .trim()
  }

  // MARK: - Filtrado en tiempo real

  /**
   * Recorre las tarjetas y muestra u oculta según texto y categoría.
   * Se opera sobre el DOM ya existente: no hay recarga ni petición al servidor.
   */
  function applyFilters() {
    var query = normalize(searchInput.value)
    var terms = query.length > 0 ? query.split(/\s+/) : []

    var cards = listContainer.querySelectorAll('.menu-card')
    var visible = 0

    Array.prototype.forEach.call(cards, function (card) {
      var haystack = card.getAttribute('data-search') || ''
      var category = card.getAttribute('data-category') || ''

      var matchesCategory = activeCategory === 'all' || category === activeCategory
      var matchesQuery = terms.every(function (term) {
        return haystack.indexOf(term) !== -1
      })

      var isVisible = matchesCategory && matchesQuery
      card.hidden = !isVisible
      if (isVisible) visible += 1
    })

    // Oculta las secciones que se hayan quedado sin tarjetas visibles.
    var sections = listContainer.querySelectorAll('.menu-section')
    Array.prototype.forEach.call(sections, function (section) {
      var visibleInSection = section.querySelectorAll('.menu-card:not([hidden])').length
      section.hidden = visibleInSection === 0
    })

    // Estado vacío y contador de resultados.
    var hasResults = visible > 0
    emptyState.hidden = hasResults
    resultsCount.textContent = hasResults
      ? visible + (visible === 1 ? ' plato' : ' platos')
      : 'Sin resultados'

    // El botón de limpiar solo aparece cuando hay texto escrito.
    clearButton.hidden = searchInput.value.length === 0
  }

  // MARK: - Vista de detalle

  function priceLabel(value) {
    return '€ ' + value.toLocaleString('es-ES', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
  }

  function renderDetail(item) {
    document.getElementById('detail-eyebrow').textContent = item.categoryName
    document.getElementById('detail-title').textContent = item.name

    var html = ''

    // Precio y disponibilidad
    html += '<div class="detail-price-row">'
    html += '<span class="detail-price">' + escapeHtml(item.priceLabel) + '</span>'
    html += item.available
      ? '<span class="detail-badge is-ok">Disponible</span>'
      : '<span class="detail-badge is-off">Agotado</span>'
    html += '</div>'

    // Descripción
    html += '<p class="detail-desc">' + escapeHtml(item.description) + '</p>'

    // Etiquetas comerciales
    if (item.tags && item.tags.length > 0) {
      html += '<div class="detail-tags">'
      item.tags.forEach(function (tag) {
        html += '<span class="tag">' + escapeHtml(tag) + '</span>'
      })
      html += '</div>'
    }

    // Metadatos
    html += '<dl class="detail-meta">'
    html +=
      '<div class="meta-item"><dt class="meta-label">Tiempo de elaboración</dt>' +
      '<dd class="meta-value">' +
      escapeHtml(item.prepTime) +
      ' min</dd></div>'
    html +=
      '<div class="meta-item"><dt class="meta-label">Alérgenos</dt>' +
      '<dd class="meta-value">' +
      escapeHtml(item.allergens && item.allergens.length > 0 ? item.allergens.join(', ') : 'Ninguno declarado') +
      '</dd></div>'
    html += '</dl>'

    // Opciones de personalización
    if (item.modifiers && item.modifiers.length > 0) {
      html += '<section class="detail-block">'
      html += '<h3 class="detail-block-title">Opciones de personalización</h3>'

      item.modifiers.forEach(function (group) {
        html += '<div class="mod-group">'
        html += '<div class="mod-group-head">'
        html += '<span class="mod-name">' + escapeHtml(group.name) + '</span>'
        html +=
          '<span class="mod-flag">' + (group.required ? 'Obligatorio' : 'Opcional') + '</span>'
        html += '</div>'
        html += '<ul class="mod-options">'

        group.options.forEach(function (option) {
          html += '<li class="mod-option">'
          html += '<span class="mod-option-name">' + escapeHtml(option.name) + '</span>'
          html +=
            '<span class="mod-option-price">' +
            (option.price > 0 ? '+' + escapeHtml(priceLabel(option.price)) : 'Incluido') +
            '</span>'
          html += '</li>'
        })

        html += '</ul></div>'
      })

      html += '</section>'
    }

    // Enlace permanente a la página de detalle (compartir / sin JS).
    html +=
      '<a class="detail-permalink" href="/item/' +
      encodeURIComponent(item.id) +
      '">Abrir en página completa</a>'

    document.getElementById('detail-body').innerHTML = html
  }

  var lastFocused = null

  function openDetail(id) {
    var item = itemsById[id]
    if (!item) return

    lastFocused = document.activeElement
    renderDetail(item)

    overlay.hidden = false
    // Fuerza el reflow para que la transición de entrada se reproduzca.
    void overlay.offsetWidth
    overlay.classList.add('is-open')
    document.body.classList.add('has-overlay')

    var closeButton = document.getElementById('detail-close')
    if (closeButton) closeButton.focus()
  }

  function closeDetail() {
    if (overlay.hidden) return

    overlay.classList.remove('is-open')
    document.body.classList.remove('has-overlay')

    window.setTimeout(function () {
      overlay.hidden = true
    }, 200)

    if (lastFocused && typeof lastFocused.focus === 'function') {
      lastFocused.focus()
    }
  }

  // MARK: - Eventos

  // Búsqueda instantánea mientras se escribe.
  searchInput.addEventListener('input', applyFilters)

  // Escape limpia el buscador.
  searchInput.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
      searchInput.value = ''
      applyFilters()
    }
  })

  clearButton.addEventListener('click', function () {
    searchInput.value = ''
    applyFilters()
    searchInput.focus()
  })

  resetButton.addEventListener('click', function () {
    searchInput.value = ''
    activeCategory = 'all'
    syncChips()
    applyFilters()
  })

  // Selección de categoría.
  chipsContainer.addEventListener('click', function (event) {
    var chip = event.target.closest('.chip')
    if (!chip) return

    activeCategory = chip.getAttribute('data-category') || 'all'
    syncChips()
    applyFilters()
  })

  function syncChips() {
    var chips = chipsContainer.querySelectorAll('.chip')
    Array.prototype.forEach.call(chips, function (chip) {
      var isActive = chip.getAttribute('data-category') === activeCategory
      chip.classList.toggle('is-active', isActive)
      chip.setAttribute('aria-pressed', isActive ? 'true' : 'false')
    })
  }

  // Apertura del detalle al pulsar cualquier plato.
  listContainer.addEventListener('click', function (event) {
    var card = event.target.closest('.menu-card')
    if (!card) return

    var id = card.getAttribute('data-id')
    if (id) openDetail(id)
  })

  // Cierre del detalle: botón, fondo y tecla Escape.
  overlay.addEventListener('click', function (event) {
    if (event.target.closest('[data-close]')) closeDetail()
  })

  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && !overlay.hidden) closeDetail()
  })

  // Trabajo de foco dentro del diálogo.
  overlay.addEventListener('keydown', function (event) {
    if (event.key !== 'Tab' || overlay.hidden) return

    var focusables = overlay.querySelectorAll('button, a[href]')
    if (focusables.length === 0) return

    var first = focusables[0]
    var last = focusables[focusables.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  })

  // El buscador del formulario queda operativo también sin JavaScript;
  // aquí se evita el envío para no recargar la página.
  var form = document.getElementById('search-form')
  if (form) {
    form.addEventListener('submit', function (event) {
      event.preventDefault()
      applyFilters()
    })
  }

  // Estado inicial coherente con lo que muestra el servidor.
  applyFilters()
})()
