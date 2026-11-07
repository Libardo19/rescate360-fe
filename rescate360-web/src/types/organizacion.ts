// Tabla `organizaciones` (modelo BD v2).
export type TipoOrganizacion = 'bomberos' | 'policia' | 'cruz_roja' | 'defensa_civil' | 'ong' | 'otro'

export interface Organizacion {
  id: string
  nombre: string
  tipo: TipoOrganizacion
  telefonoContacto: string
  activa: boolean
}

export const etiquetaTipoOrganizacion: Record<TipoOrganizacion, string> = {
  bomberos: 'Bomberos',
  policia: 'Policía',
  cruz_roja: 'Cruz Roja',
  defensa_civil: 'Defensa Civil',
  ong: 'ONG',
  otro: 'Otro',
}
