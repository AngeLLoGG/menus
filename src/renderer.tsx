import { jsxRenderer } from 'hono/jsx-renderer'

type RendererProps = {
  title?: string
}

export const renderer = jsxRenderer(({ children, title }: RendererProps) => {
  const pageTitle = title ?? 'Atelier Bistro · Carta Digital'

  return (
    <html lang="es">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="description" content="Carta digital de Atelier Bistro con búsqueda en tiempo real." />
        <meta name="color-scheme" content="light" />
        <title>{pageTitle}</title>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap"
          rel="stylesheet"
        />
        <link href="/static/style.css" rel="stylesheet" />
      </head>
      <body>{children}</body>
    </html>
  )
})
