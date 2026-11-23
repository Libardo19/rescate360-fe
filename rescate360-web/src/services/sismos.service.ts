import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { CheckInsEventoApi, CheckInsSismo, RegionSismo, Sismo, SismoApi } from '../types/sismo'

export const aSismo = (s: SismoApi): Sismo => ({
  id: s.id,
  fuente: s.fuente,
  magnitud: s.magnitud,
  profundidadKm: s.profundidad_km,
  lugar: s.lugar,
  lat: s.epicentro.lat,
  lng: s.epicentro.lng,
  ocurridoEn: s.ocurrido_en,
  radioAfectacionM: s.radio_afectacion_m,
  alertaId: s.alerta_id,
  enColombia: s.en_colombia,
})

const hace = (minutos: number) => new Date(Date.now() - minutos * 60_000).toISOString()

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
let mock: Sismo[] = [
  { id: 'm1', fuente: 'usgs', magnitud: 4.7, profundidadKm: 140, lugar: '12 km SW of Los Santos, Colombia', lat: 6.75, lng: -73.18, ocurridoEn: hace(35), radioAfectacionM: 11_487, alertaId: 'a1', enColombia: true },
  { id: 'm2', fuente: 'usgs', magnitud: 6.1, profundidadKm: 35, lugar: '85 km E of Hualien City, Taiwan', lat: 23.9, lng: 122.4, ocurridoEn: hace(90), radioAfectacionM: 30_314, alertaId: null, enColombia: false },
  { id: 'm3', fuente: 'usgs', magnitud: 2.9, profundidadKm: 8, lugar: '5 km N of Ridgecrest, CA', lat: 35.67, lng: -117.67, ocurridoEn: hace(140), radioAfectacionM: 3_299, alertaId: null, enColombia: false },
  { id: 'm4', fuente: 'usgs', magnitud: 5.3, profundidadKm: 60, lugar: 'offshore Valparaíso, Chile', lat: -33.2, lng: -72.1, ocurridoEn: hace(300), radioAfectacionM: 17_411, alertaId: null, enColombia: false },
]

export async function listarSismos(region: RegionSismo, magnitudMin?: number): Promise<Sismo[]> {
  if (USE_MOCK) {
    return mock.filter(
      (s) => (region === 'todos' || s.enColombia === (region === 'colombia')) && (magnitudMin === undefined || s.magnitud >= magnitudMin),
    )
  }
  const pagina = await api<Pagina<SismoApi>>(
    `/sismos${consulta({ por_pagina: 100, region: region === 'todos' ? undefined : region, magnitud_min: magnitudMin })}`,
  )
  return pagina.items.map(aSismo)
}

// Quién respondió el "¿Estás bien?" de un sismo con alerta
export async function checkInsDeSismo(id: string): Promise<CheckInsSismo> {
  if (USE_MOCK) {
    return {
      resumen: { pendiente: 2, a_salvo: 5, necesito_ayuda: 1, sin_respuesta: 0 },
      personas: [
        { id: 'c1', nombre: 'Ana Pérez', telefono: '3001234567', estado: 'necesito_ayuda', respondidoEn: hace(20) },
        { id: 'c2', nombre: 'Luis Gómez', telefono: null, estado: 'pendiente', respondidoEn: null },
      ],
    }
  }
  const datos = await api<CheckInsEventoApi>(`/check-ins${consulta({ evento_sismico_id: id })}`)
  return {
    resumen: datos.resumen,
    personas: datos.personas.map((p) => ({ id: p.id, nombre: p.nombre, telefono: p.telefono, estado: p.estado, respondidoEn: p.respondido_en })),
  }
}

// Simulacro para la demo: solo super admin y solo con el backend en local
export async function simularSismo(magnitud: number): Promise<Sismo> {
  if (USE_MOCK) {
    const nuevo: Sismo = { id: `sim${Date.now()}`, fuente: 'simulado', magnitud, profundidadKm: 10, lugar: 'Simulacro · Valledupar, Cesar', lat: 10.4631, lng: -73.2532, ocurridoEn: new Date().toISOString(), radioAfectacionM: 10_000, alertaId: 'sim', enColombia: true }
    mock = [nuevo, ...mock]
    return nuevo
  }
  return aSismo(await api<SismoApi>('/sismos/simular', { method: 'POST', body: JSON.stringify({ magnitud }) }))
}
