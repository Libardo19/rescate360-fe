import { useEffect, useRef } from 'react'

// Cada cuánto se refrescan las listas del panel (el mapa usa su propio intervalo)
export const REFRESCO_MS = 20_000

// Llama `consultar` al montar y luego cada `ms`, salvo con la pestaña oculta (ahorra peticiones).
// Así el admin ve el cambio cuando el voluntario finaliza un caso, sin recargar la página.
export function useConsultaPeriodica(consultar: () => void, ms = REFRESCO_MS) {
  const ultima = useRef(consultar)
  useEffect(() => {
    ultima.current = consultar
  })

  useEffect(() => {
    ultima.current()
    const intervalo = setInterval(() => {
      if (!document.hidden) ultima.current()
    }, ms)
    return () => clearInterval(intervalo)
  }, [ms])
}
