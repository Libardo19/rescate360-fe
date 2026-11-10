// Capas del mapa: las mismas que devuelve GET /mapa. Centros, zonas y alertas llegan vacías
// hasta que existan sus módulos en el backend.
export type TipoPunto = 'solicitud' | 'reporte' | 'centro' | 'zona' | 'alerta'

// PuntoMapa del backend (igual para la app y el panel)
export interface PuntoMapa {
  id: string
  capa: TipoPunto
  tipo: string
  titulo: string
  detalle: string
  estado: string
  prioridad: string | null
  lat: number
  lng: number
  radio_m: number | null
  aproximada: boolean // posición redondeada (~200 m): no es de mi organización
  propio: boolean
  activo: boolean // false = se cerró: se quita del mapa
  actualizado_en: string
}

export interface MapaOut {
  puntos: PuntoMapa[]
  generado_en: string // se manda como `desde` en la siguiente consulta
}
