import { useEffect, useState } from 'react'

// Semáforo de tiempo de respuesta para solicitudes sin atender.
// Umbrales: ámbar a los 15 min, rojo a los 30 min.
export const UMBRAL_ATENCION_MIN = 15
export const UMBRAL_CRITICO_MIN = 30

export type NivelEspera = 'ok' | 'atencion' | 'critico'

export const minutosDesde = (iso: string, ahora: number) => Math.max(0, Math.floor((ahora - new Date(iso).getTime()) / 60000))

export const nivelEspera = (minutos: number): NivelEspera =>
  minutos >= UMBRAL_CRITICO_MIN ? 'critico' : minutos >= UMBRAL_ATENCION_MIN ? 'atencion' : 'ok'

export function textoEspera(minutos: number) {
  if (minutos < 1) return 'ahora'
  if (minutos < 60) return `${minutos} min`
  const horas = Math.floor(minutos / 60)
  if (horas < 24) return `${horas} h ${String(minutos % 60).padStart(2, '0')} min`
  const dias = Math.floor(horas / 24)
  return `${dias} ${dias === 1 ? 'día' : 'días'}`
}

// Hora actual que se actualiza sola (por defecto cada 30 s) para que los contadores avancen.
export function useAhora(cadaMs = 30_000) {
  const [ahora, setAhora] = useState(() => Date.now())
  useEffect(() => {
    const id = window.setInterval(() => setAhora(Date.now()), cadaMs)
    return () => window.clearInterval(id)
  }, [cadaMs])
  return ahora
}
