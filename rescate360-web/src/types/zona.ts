// Tabla `zonas_peligrosas` (modelo BD v2).
export type EstadoZona = 'activa' | 'resuelta'
export type TipoRiesgo = 'inundacion' | 'deslizamiento' | 'incendio' | 'inseguridad' | 'estructural' | 'otro'

// Punto [latitud, longitud]. El backend lo guarda como GEOGRAPHY(POLYGON).
export type Coordenada = [number, number]

export interface ZonaPeligrosa {
  id: string
  tipoRiesgo: TipoRiesgo
  area: Coordenada[] // vértices del polígono, sin repetir el primero al final
  estado: EstadoZona
  gestionadoPor: string // nombre de quien la gestiona
  actualizadoEn: string // formato ISO
}

export type NuevaZona = Pick<ZonaPeligrosa, 'tipoRiesgo' | 'area'>

// Área aproximada en hectáreas (suficiente para mostrar en el panel; el cálculo real lo hace PostGIS).
export function hectareas(area: Coordenada[]): number {
  if (area.length < 3) return 0
  const lat0 = (area.reduce((s, [lat]) => s + lat, 0) / area.length) * (Math.PI / 180)
  const puntos = area.map(([lat, lng]) => [lng * 111320 * Math.cos(lat0), lat * 110540])
  let suma = 0
  puntos.forEach(([x1, y1], i) => {
    const [x2, y2] = puntos[(i + 1) % puntos.length]
    suma += x1 * y2 - x2 * y1
  })
  return Math.abs(suma) / 2 / 10000
}
