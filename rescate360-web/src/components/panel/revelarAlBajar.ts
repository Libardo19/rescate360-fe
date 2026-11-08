import { useEffect, type RefObject } from 'react'

// Qué aparece al hacer scroll en cada pantalla del panel:
// - los bloques principales de la página (cabecera, filtros, tablas, paneles),
// - las tarjetas dentro de grillas (franja de cifras, listas en tarjetas),
// - las filas de las tablas.
const SELECTOR = [
  '.panel-page-enter > div > *:not(.fixed)',
  '.panel-page-enter .grid > *',
  '.panel-page-enter tbody tr',
].join(', ')

// Nunca dentro de ventanas modales, mapas, el Inicio (usa sus propias animaciones) ni la paleta.
const EXCLUIR = '.fixed, .leaflet-container, .sin-cascada, [role="dialog"]'

const PASO_MS = 70 // retraso entre elementos que entran a la vez
const MAX_MS = 420

// Marca los elementos como ocultos y los revela al entrar en pantalla, en cascada.
// Usa atributos data-* (no clases) para no chocar con las clases que pone React.
export function useRevelarAlBajar(contenedor: RefObject<HTMLElement | null>, clave: string) {
  useEffect(() => {
    const raiz = contenedor.current
    if (!raiz || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return

    const observador = new IntersectionObserver(
      (entradas) => {
        const visibles = entradas.filter((e) => e.isIntersecting).map((e) => e.target as HTMLElement)
        // Orden visual (de arriba abajo, de izquierda a derecha) para que la cascada se vea natural.
        visibles.sort((a, b) => {
          const ra = a.getBoundingClientRect()
          const rb = b.getBoundingClientRect()
          return ra.top - rb.top || ra.left - rb.left
        })
        visibles.forEach((el, i) => {
          el.style.setProperty('--retraso', `${Math.min(i * PASO_MS, MAX_MS)}ms`)
          el.dataset.revelar = 'visible'
          observador.unobserve(el)
        })
      },
      { rootMargin: '0px 0px -8% 0px', threshold: 0.08 },
    )

    const preparar = () => {
      raiz.querySelectorAll<HTMLElement>(SELECTOR).forEach((el) => {
        if (el.dataset.revelar || el.closest(EXCLUIR)) return
        el.dataset.revelar = 'oculto'
        observador.observe(el)
      })
    }

    preparar()
    // Las pantallas cargan sus datos después ("Cargando…"): se preparan también los elementos nuevos.
    const mutaciones = new MutationObserver(preparar)
    mutaciones.observe(raiz, { childList: true, subtree: true })

    return () => {
      mutaciones.disconnect()
      observador.disconnect()
    }
  }, [contenedor, clave])
}
