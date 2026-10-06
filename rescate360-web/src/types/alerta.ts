export type TipoAlerta = 'inundacion' | 'deslizamiento' | 'seguridad' | 'clima' | 'otro'

export interface Alerta {
  id: string
  tipo: TipoAlerta
  titulo: string
  descripcion: string
  zona: string
  fecha: string // formato ISO
  activa: boolean
}

export type NuevaAlerta = Pick<Alerta, 'tipo' | 'titulo' | 'descripcion' | 'zona'>