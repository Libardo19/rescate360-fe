export type TipoOrganizacion = 'bomberos' | 'policia' | 'cruz_roja' | 'defensa_civil' | 'ong' | 'otro'

export const TIPOS_ORGANIZACION: Record<TipoOrganizacion, string> = {
  bomberos: 'Bomberos',
  policia: 'Policía',
  cruz_roja: 'Cruz Roja',
  defensa_civil: 'Defensa Civil',
  ong: 'ONG',
  otro: 'Otra',
}

// OrganizacionOut del backend
export interface Organizacion {
  id: string
  nombre: string
  tipo: TipoOrganizacion
  telefono_contacto: string | null
  activa: boolean
  creado_en: string
}

export interface DatosOrganizacion {
  nombre: string
  tipo: TipoOrganizacion
  telefono_contacto?: string
}

export type CambiosOrganizacion = Partial<DatosOrganizacion & { activa: boolean }>
