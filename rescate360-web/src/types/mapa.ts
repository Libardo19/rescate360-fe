export type TipoPunto = 'reporte' | 'solicitud' | 'centro'

export interface PuntoMapa {
  id: string
  tipo: TipoPunto
  titulo: string
  detalle: string
  estado: string
  lat: number
  lng: number
}