import { useEffect, type RefObject } from 'react'

// En móvil las tablas del panel se muestran como tarjetas (ver index.css, "Tablas en móvil").
// Para eso cada celda necesita el nombre de su columna: se copia del <thead> a data-label.
// Las columnas de texto largo ocupan todo el ancho de la tarjeta (data-completo).
const COLUMNAS_ANCHAS = ['descripción', 'usuario', 'nombre', 'cambio']

function etiquetar(raiz: HTMLElement) {
  raiz.querySelectorAll<HTMLTableElement>('table[class*="min-w-"]').forEach((tabla) => {
    if (tabla.closest('.fixed')) return // las tablas dentro de ventanas modales se dejan igual
    tabla.dataset.movil = 'tarjetas'
    const titulos = [...tabla.querySelectorAll('thead th')].map((th) => th.textContent?.trim() ?? '')
    tabla.querySelectorAll('tbody tr').forEach((fila) => {
      let columna = 0
      ;[...fila.children].forEach((celda) => {
        const td = celda as HTMLTableCellElement
        const titulo = titulos[columna] ?? ''
        if (td.colSpan > 1) td.dataset.completo = 'si'
        else if (!titulo || titulo.toLowerCase() === 'acciones') {
          td.dataset.label = ''
          td.dataset.acciones = 'si'
        } else {
          if (td.dataset.label !== titulo) td.dataset.label = titulo
          if (COLUMNAS_ANCHAS.includes(titulo.toLowerCase())) td.dataset.completo = 'si'
        }
        columna += td.colSpan || 1
      })
    })
  })
}

export function useTablasMovil(contenedor: RefObject<HTMLElement | null>, clave: string) {
  useEffect(() => {
    const raiz = contenedor.current
    if (!raiz) return
    etiquetar(raiz)
    // Las filas cambian al cargar datos o filtrar: se vuelven a etiquetar.
    const mutaciones = new MutationObserver(() => etiquetar(raiz))
    mutaciones.observe(raiz, { childList: true, subtree: true })
    return () => mutaciones.disconnect()
  }, [contenedor, clave])
}
